Revision: 1

Choose test coverage from module responsibilities, dependencies, and external
boundaries. Test organization and language-specific filename conventions belong
to the installed convention documents and project policies.

# Coverage by responsibility

- Use unit tests for isolated module behavior. Lowest-level shared and feature
  modules normally need only unit coverage unless they own an external boundary.
- Use orchestration tests for feature coordination: mock lower layers and check
  arguments, transactions, fallbacks, and error propagation. Features with both
  isolated and coordinating behavior need both kinds of coverage.
- Use focused integration tests against real external boundaries without mocks.
  An infrastructure adapter needs coverage for every boundary it owns.
- Give entry modules unit coverage and comprehensive integration coverage of
  their composition; use orchestration tests at the feature level.
- Use performance tests to measure a module's own latency, throughput, memory,
  or other resource use under a defined workload, without comparing competing
  implementations or baselines. Record the measured values and assert absolute
  budgets when the module has a performance contract. For example, measure a
  Library read model at realistic material and dictionary counts.
- Use benchmarks to compare implementations, configurations, versions, or a
  reference baseline under equivalent workloads. Comparisons may concern speed,
  resource use, or result quality. For example, compare fast and deep
  lemmatizers' duration, accuracy, and recall on the same corpus and annotated
  reference data.

Choose performance and benchmark coverage when a resource contract or comparison
question warrants it, rather than requiring both for every module. Keep fixture
setup outside timed regions, use warmup and repeated samples where appropriate,
and record workload and execution conditions so measurements are interpretable.

Build confidence from lower modules upward. Higher tests should verify their own
coordination or integration guarantees without repeating lower modules' detailed
assertions.

# Public interface coverage

Test through the real public interface. Do not export ordinary private helpers
solely for tests. If a complicated internal workflow needs direct coverage, use
a narrow documented test-facing export with a declaration-level suppression
where the project permits it. Do not apply blanket suppressions.

# Acceptance

Run the selected suites and review whether the tests prove their intended
behavior. Structural checks cannot establish test category, mock discipline,
boundary coverage, or assertion quality.
