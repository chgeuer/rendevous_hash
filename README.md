# RendevousHash

An Elixir implementation of **rendezvous hashing** (also known as highest random weight hashing) with advanced replica placement strategies for distributed systems.

## What is Rendezvous Hashing?

Rendezvous hashing is a distributed hashing technique that provides excellent load balancing and minimal key redistribution when nodes are added or removed. Unlike consistent hashing, it doesn't require a hash ring and naturally handles uneven node weights.

### Key Benefits

- **Perfect Load Balancing**: Distributes keys evenly across all nodes
- **Minimal Redistribution**: Only affected keys move when nodes change
- **Deterministic**: Same input always produces same node ordering
- **High Performance**: Native Rust implementation via NIFs
- **Optimized for Multiple Keys**: Pre-computed node hashes eliminate redundant calculations

## Architecture

This project provides both **pure Elixir** and **native Rust** implementations:

- **RendevousHash.Native**: High-performance Rust implementation via Rustler NIFs
- **RendevousHash.Elixir**: Pure Elixir fallback with advanced replica selection
- **Unified API**: Seamless switching between implementations

## Quick Start

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:rendevous_hash, "~> 0.1.0"}
  ]
end
```

### Basic Usage

```elixir
# Define your compute nodes

nodes = [
  %ComputeNode{region: "eastus", zone: "1", id: "0001"},
  %ComputeNode{region: "eastus", zone: "2", id: "0002"},
  %ComputeNode{region: "westeurope", zone: "1", id: "0003"},
  %ComputeNode{region: "westeurope", zone: "2", id: "0004"},
  ComputeNode.new("westeurope", "2", 5)
]

# Pre-compute node hashes once for optimal performance
# This eliminates redundant hashing when looking up multiple keys
node_hashes = RendevousHash.pre_compute_list(nodes)

# Find the best node for a key
leader = RendevousHash.get_leader(node_hashes, "my-data-key")

# Get ordered list of nodes (for replication)
ordered_nodes = RendevousHash.list(node_hashes, "my-data-key")
```

### Advanced Replica Placement

Intelligent replica selection with geographic distribution

```elixir
replicas = [primary, same_region_replica, different_region_replica] = 
    ordered_nodes
    |> RendevousHash.sort_by_optimum_storage_resiliency(3)

# Result: [primary, same_region_replica, different_region_replica]
# - Primary: Best node for the key
# - Same region replica: Fast failover within region
# - Cross-region replica: Disaster recovery protection
```

## Visualization

Generate SVG visualizations to understand your distributed system layout:

```elixir
# Visualize replica placement strategy
svg = Drawing.generate_svg(nodes, replica_count: 2)
File.write!("replication_strategy.svg", svg)

# Advanced grid-based visualization
svg = Drawing.generate_svg(nodes, replica_count: 3)
File.write!("advanced_layout.svg", svg)
```

The visualizations show:
- **Primary replicas** (thick red arrows)
- **Main replicas** (medium blue arrows)
- **Less critical replicas** (thin blue arrows)
- **Unused nodes** (gray)
- **Geographic organization** (regions and availability zones)

## Analysis & Testing

### Distribution Analysis
```elixir
# Validate replica selection consistency
DistributionAnalyzer.analyze_consistency(nodes, max_replicas: 5)

# Test that shorter replica lists are prefixes of longer ones
DistributionAnalyzer.validate_prefix_consistency(nodes)
```

### Impact Simulation
```elixir
# Simulate node failures and measure impact
NodeImpactSimulator.run_simulation(nodes,
  failure_scenarios: [:single_node, :zone_failure, :region_failure])

# Analyze distribution variance
NodeImpactSimulator.analyze_distribution_balance(nodes, key_count: 10000)
```

## Core Concepts

### ComputeNode Structure
```elixir
%ComputeNode{
  region: "eastus",     # Azure region (disaster recovery)
  zone: "1",            # Availability zone (fault isolation)
  id: "0001"           # Unique VM identifier
}
```

### Replica Selection Strategy

The advanced replica selection algorithm prioritizes:

1. **Same Region, Different Zone**: Fast failover with fault isolation
2. **Different Regions**: Geographic diversity for disaster recovery
3. **Load Balancing**: Even distribution across all resources
4. **Consistency**: Deterministic placement regardless of replica count

## Development

### Running Tests
```bash
mix test
```

### Code Quality
```bash
mix credo --strict
```

### Interactive Development
Open the LiveBook demo:
```bash
livebook server contents/demo.livemd
```

### Performance Benchmarking
The project includes comprehensive benchmarks comparing:
- Rust vs Elixir implementations
- Different key distribution patterns
- Replica selection algorithms

## Implementation Details

### Dual Implementation Strategy
- **Rust NIFs**: Maximum performance for hot paths (hashing, sorting)
- **Pure Elixir**: Complex algorithms (replica selection, geographic optimization)
- **Graceful Fallback**: Automatic fallback to Elixir if NIFs unavailable

### Hash Function
Uses **Murmur3** hash for:
- Excellent distribution properties
- Fast computation
- Cross-platform consistency

### Performance Optimization
- **Pre-computed Node Hashes**: Node hashes are calculated once and reused for all key lookups, dramatically improving performance when processing multiple keys against the same node set
- **CPU Efficiency**: Eliminates redundant hash calculations during high-throughput operations
- **Memory Efficiency**: Streaming operations for large node sets with minimal allocations in hot paths

## References

- [Rendezvous Hashing (Wikipedia)](https://en.wikipedia.org/wiki/Rendezvous_hashing)
- [Computation-Efficient Rendezvous Hashing](https://www.npiontko.pro/2024/12/23/computation-efficient-rendezvous-hashing)
- [Consistent Hashing vs Rendezvous Hashing](https://medium.com/@dgryski/consistent-hashing-algorithmic-tradeoffs-ef6b8e2fcae8)
- [Waterpark: Transforming Healthcare with Distributed Actors - Bryan Hunter - NDC Oslo 2025](https://www.youtube.com/watch?v=hdBm4K-vvt0)

## License

Apache 2.0

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Run `mix format && mix credo --strict` to ensure code quality
5. Submit a pull request

## Research Applications

This implementation is particularly useful for:

- **Distributed Databases**: Replica placement and data sharding
- **Content Delivery Networks**: Origin server selection
- **Load Balancers**: Backend server selection with minimal disruption
- **Distributed Storage**: Geographic data placement optimization
- **Research**: Algorithm comparison and distributed systems education