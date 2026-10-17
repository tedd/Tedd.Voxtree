using Tedd.Voxtree.Simulations;

namespace Tedd.Voxtree.Tests;

public class SimulationTests
{
    [Theory]
    [InlineData(SimulationKind.Water, 2)]
    [InlineData(SimulationKind.Water, 3)]
    [InlineData(SimulationKind.Water, 5)]
    [InlineData(SimulationKind.Heat, 2)]
    [InlineData(SimulationKind.Heat, 3)]
    [InlineData(SimulationKind.Heat, 5)]
    [InlineData(SimulationKind.Tracer, 2)]
    [InlineData(SimulationKind.Tracer, 3)]
    [InlineData(SimulationKind.Tracer, 5)]
    public void EveryStepMatchesConservativeFlatReference(SimulationKind kind, int levels)
    {
        var linear = new SimulationWorkload(levels, kind, SimulationAccess.Linear);
        var random = new SimulationWorkload(levels, kind, SimulationAccess.Random, 7919);
        var expected = linear.Snapshot();
        var initial = (uint[])expected.Clone();
        var total = linear.Checksum();
        for (var step = 0; step < 24; step++)
        {
            expected = ReferenceStep(expected, 1 << levels, kind);
            linear.Step();
            random.Step();
            Assert.Equal(expected, linear.Snapshot());
            Assert.Equal(expected, random.Snapshot());
            Assert.Equal(total, linear.Checksum());
            Assert.Equal(total, random.Checksum());
        }
        Assert.False(initial.SequenceEqual(expected));
        Assert.True(expected.Count(v => v > 0) > initial.Count(v => v > 0));
        linear.Reset();
        random.Reset();
        Assert.Equal(initial, linear.Snapshot());
        Assert.Equal(initial, random.Snapshot());
        Assert.Equal(linear.Run(8), random.Run(8));
        Assert.Equal(linear.Snapshot(), random.Snapshot());
    }

    // Independent edge-scatter oracle: visit each edge once and add equal/opposite
    // transfers. The workload instead gathers all neighbors of each destination.
    private static uint[] ReferenceStep(uint[] source, int side, SimulationKind kind)
    {
        var result = source.Select(v => (long)v).ToArray();
        var water = kind == SimulationKind.Water;
        var height = water ? 1 : side;
        int Index(int x, int y, int z) => (x * height + y) * side + z;
        long Ground(int x, int z) => water ? (side - x) * 32 + z % 3 * 8 : 0;
        for (var x = 0; x < side; x++)
        for (var y = 0; y < height; y++)
        for (var z = 0; z < side; z++)
        {
            var a = Index(x, y, z);
            void Transfer(int nx, int ny, int nz)
            {
                var b = Index(nx, ny, nz);
                var difference = ((long)source[a] + Ground(x, z) - source[b] - Ground(nx, nz)) /
                    (kind == SimulationKind.Tracer ? 16 : 8);
                var amount = water
                    ? (difference > 0 ? Math.Min(difference, source[a] / 4) : -Math.Min(-difference, source[b] / 4))
                    : difference;
                result[a] -= amount;
                result[b] += amount;
            }
            if (x + 1 < side) Transfer(x + 1, y, z);
            if (y + 1 < height) Transfer(x, y + 1, z);
            if (z + 1 < side) Transfer(x, y, z + 1);
        }
        return result.Select(v => checked((uint)v)).ToArray();
    }

    [Fact]
    public void HeatAndTracerRemainSymmetricAndBounded()
    {
        foreach (var kind in new[] { SimulationKind.Heat, SimulationKind.Tracer })
        {
            var workload = new SimulationWorkload(3, kind, SimulationAccess.Random);
            workload.Run(3);
            var values = workload.Snapshot();
            Assert.Equal(values[(3 * 8 + 4) * 8 + 4], values[(5 * 8 + 4) * 8 + 4]);
            Assert.Equal(values[(4 * 8 + 3) * 8 + 4], values[(4 * 8 + 5) * 8 + 4]);
            Assert.All(values, value => Assert.InRange(value, 0u, 1_000_000u));
        }
    }
}
