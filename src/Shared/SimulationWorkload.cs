using System;
using Tedd.Voxtree;

namespace Tedd.Voxtree.Simulations;

public enum SimulationKind { Water, Heat, Tracer }
public enum SimulationAccess { Linear, Random }

// Shared by correctness tests and benchmarks. Integer fluxes make conservation exact.
public sealed class SimulationWorkload
{
    private readonly HotOctreeChunk _first;
    private readonly HotOctreeChunk _second;
    private HotOctreeChunk _current;
    private HotOctreeChunk _next;
    private readonly int[] _order;
    private readonly uint[] _initial;
    private readonly int _side;
    public SimulationKind Kind { get; }
    public int Count => _order.Length;

    public SimulationWorkload(int levels, SimulationKind kind, SimulationAccess access, int seed = 1729)
    {
        if (levels < 1 || levels > 6) throw new ArgumentOutOfRangeException(nameof(levels));
        Kind = kind;
        _side = 1 << levels;
        _first = HotOctreeChunk.Empty(levels, 2);
        _second = HotOctreeChunk.Empty(levels, 2);
        _current = _first;
        _next = _second;
        _order = new int[kind == SimulationKind.Water ? _side * _side : _side * _side * _side];
        _initial = new uint[_order.Length];
        for (var i = 0; i < _order.Length; i++)
        {
            _order[i] = i;
            Decode(i, out var x, out var y, out var z);
            var center = _side / 2;
            _initial[i] = kind == SimulationKind.Water
                ? (x < center ? 4096u : 0u)
                : (x == center && y == center && z == center ? 1_000_000u : 0u);
            var terrain = (uint)((_side - x) * 32 + (z % 3) * 8);
            _first[1, x, y, z] = terrain;
            _second[1, x, y, z] = terrain;
        }
        if (access == SimulationAccess.Random)
        {
            // Fixed algorithm: reproducible permutations across runtime versions.
            var state = (uint)seed;
            for (var i = _order.Length - 1; i > 0; i--)
            {
                state = unchecked(state * 1664525u + 1013904223u);
                var j = (int)(state % (uint)(i + 1));
                (_order[i], _order[j]) = (_order[j], _order[i]);
            }
        }
        Reset();
    }

    public void Reset()
    {
        _current = _first;
        _next = _second;
        _first.GetChannelSpan(0).Clear();
        _second.GetChannelSpan(0).Clear();
        for (var i = 0; i < _initial.Length; i++)
        {
            Decode(i, out var x, out var y, out var z);
            _first[0, x, y, z] = _initial[i];
        }
    }

    public void Step()
    {
        foreach (var i in _order)
        {
            Decode(i, out var x, out var y, out var z);
            var value = _current[0, x, y, z];
            long next = value;
            if (x > 0) next += Flux(x, y, z, x - 1, y, z, value);
            if (x + 1 < _side) next += Flux(x, y, z, x + 1, y, z, value);
            if (z > 0) next += Flux(x, y, z, x, y, z - 1, value);
            if (z + 1 < _side) next += Flux(x, y, z, x, y, z + 1, value);
            if (Kind != SimulationKind.Water)
            {
                if (y > 0) next += Flux(x, y, z, x, y - 1, z, value);
                if (y + 1 < _side) next += Flux(x, y, z, x, y + 1, z, value);
            }
            _next[0, x, y, z] = checked((uint)next);
        }
        (_current, _next) = (_next, _current);
    }

    private long Flux(int x, int y, int z, int nx, int ny, int nz, uint value)
    {
        var neighbor = _current[0, nx, ny, nz];
        if (Kind != SimulationKind.Water)
            return ((long)neighbor - value) / (Kind == SimulationKind.Heat ? 8 : 16);
        var head = (long)value + _current[1, x, y, z];
        var otherHead = (long)neighbor + _current[1, nx, ny, nz];
        var difference = (otherHead - head) / 8;
        return difference >= 0 ? Math.Min(difference, neighbor / 4) : -Math.Min(-difference, value / 4);
    }

    public ulong Run(int steps)
    {
        for (var i = 0; i < steps; i++) Step();
        return Checksum();
    }

    public ulong Checksum()
    {
        ulong sum = 0;
        foreach (var value in _current.GetChannelSpan(0)) sum += value;
        return sum;
    }

    public uint[] Snapshot()
    {
        var result = new uint[Count];
        for (var i = 0; i < result.Length; i++)
        {
            Decode(i, out var x, out var y, out var z);
            result[i] = _current[0, x, y, z];
        }
        return result;
    }

    private void Decode(int i, out int x, out int y, out int z)
    {
        z = i % _side;
        i /= _side;
        y = Kind == SimulationKind.Water ? 0 : i % _side;
        x = Kind == SimulationKind.Water ? i : i / _side;
    }
}
