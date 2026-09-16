using BenchmarkDotNet.Attributes;

namespace Tedd.Voxtree.Benchmark.Tests;

// Persistent workers exclude thread/task creation. One invocation always performs 65,536 accesses.
[MemoryDiagnoser]
public class AccessLocks
{
    private const int Operations = 65536;
    private readonly ReaderWriterLockSlim _slim = new(LockRecursionPolicy.SupportsRecursion);
    private readonly object _monitor = new();
#if NET9_0_OR_GREATER
    private readonly Lock _modern = new();
#endif
    private SpinLock _spin = new(false);
    private Barrier _start = null!, _end = null!;
    private Thread[] _workers = null!;
    private long[] _sums = null!;
    private volatile bool _stop;
    private int _mode, _value = 1;

    [Params(1, 4)] public int Workers { get; set; }
    [Params(0, 10)] public int WritePercent { get; set; }

    [GlobalSetup]
    public void Setup()
    {
        _start = new Barrier(Workers + 1);
        _end = new Barrier(Workers + 1);
        _sums = new long[Workers];
        _workers = new Thread[Workers];
        for (var i = 0; i < Workers; i++)
        {
            var worker = i;
            _workers[i] = new Thread(() => Work(worker)) { IsBackground = true };
            _workers[i].Start();
        }
    }

    [GlobalCleanup]
    public void Cleanup()
    {
        _stop = true;
        _start.SignalAndWait();
        foreach (var worker in _workers) worker.Join();
        _start.Dispose();
        _end.Dispose();
        _slim.Dispose();
    }

    [Benchmark(Baseline = true, OperationsPerInvoke = Operations)] public long Slim() => Run(0);
    [Benchmark(OperationsPerInvoke = Operations)] public long MonitorLock() => Run(1);
#if NET9_0_OR_GREATER
    [Benchmark(OperationsPerInvoke = Operations)] public long ModernLock() => Run(2);
#endif
    [Benchmark(OperationsPerInvoke = Operations)] public long SpinLock() => Run(3);
    [Benchmark(OperationsPerInvoke = Operations)] public long SpinBeforeSlim() => Run(4);

    private long Run(int mode)
    {
        _mode = mode;
        _value = 1;
        _start.SignalAndWait();
        _end.SignalAndWait();
        var expected = 1;
        for (var i = 0; i < Operations / Workers; i++)
            if (i % 100 < WritePercent) expected += Workers;
        if (_value != expected) throw new InvalidOperationException("Lost write.");
        long sum = 0;
        foreach (var value in _sums) sum += value;
        return sum;
    }

    private void Work(int worker)
    {
        while (true)
        {
            _start.SignalAndWait();
            if (_stop) return;
            long sum = 0;
            for (var i = 0; i < Operations / Workers; i++)
            {
                var write = i % 100 < WritePercent;
                switch (_mode)
                {
                    case 0:
                    case 4:
                        if (write)
                        {
                            if (_mode == 4) EnterAfterSpin(true);
                            else _slim.EnterWriteLock();
                            try { _value++; }
                            finally { _slim.ExitWriteLock(); }
                        }
                        else
                        {
                            if (_mode == 4) EnterAfterSpin(false);
                            else _slim.EnterReadLock();
                            try { sum += _value; }
                            finally { _slim.ExitReadLock(); }
                        }
                        break;
                    case 1:
                        lock (_monitor) { if (write) _value++; else sum += _value; }
                        break;
#if NET9_0_OR_GREATER
                    case 2:
                        lock (_modern) { if (write) _value++; else sum += _value; }
                        break;
#endif
                    case 3:
                        var taken = false;
                        try
                        {
                            _spin.Enter(ref taken);
                            if (write) _value++; else sum += _value;
                        }
                        finally { if (taken) _spin.Exit(); }
                        break;
                }
            }
            _sums[worker] = sum;
            _end.SignalAndWait();
        }
    }

    private void EnterAfterSpin(bool write)
    {
        var wait = new SpinWait();
        for (var retry = 0; retry < 4; retry++)
        {
            if (write ? _slim.TryEnterWriteLock(0) : _slim.TryEnterReadLock(0)) return;
            wait.SpinOnce();
        }
        if (write) _slim.EnterWriteLock();
        else _slim.EnterReadLock();
    }
}
