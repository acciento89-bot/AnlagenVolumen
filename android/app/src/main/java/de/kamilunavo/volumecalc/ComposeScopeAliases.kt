package de.kamilunavo.volumecalc

/**
 * Classifier alias used by the parity-rebuild card DSL. Call sites named
 * Column still resolve to the androidx.compose layout function in value space.
 */
internal typealias Column = androidx.compose.foundation.layout.ColumnScope
