import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../constants.dart';
import '../providers/setup_provider.dart';
import 'terminal_screen.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<SetupProvider>(
          builder: (context, provider, _) {
            final state = provider.state;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Image.asset(
                    'assets/ic_launcher.png',
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Setup Termax',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _started
                        ? 'Setting up the environment. This may take several minutes.'
                        : 'This will download Ubuntu into a self-contained environment.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: _buildSteps(state, theme),
                  ),
                  if (state.hasError) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  state.error ?? 'Unknown error',
                                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (state.isComplete)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _goToTerminal(context),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Open Terminal'),
                      ),
                    )
                  else if (!_started || state.hasError)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isRunning
                            ? null
                            : () {
                                setState(() => _started = true);
                                provider.runSetup();
                              },
                        icon: const Icon(Icons.download),
                        label: Text(_started ? 'Retry Setup' : 'Begin Setup'),
                      ),
                    ),
                  if (!_started) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Requires ~500MB of storage and an internet connection',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSteps(SetupState state, ThemeData theme) {
    final steps = [
      (1, 'Download Ubuntu rootfs', SetupStep.downloadingRootfs),
      (2, 'Extract rootfs', SetupStep.extractingRootfs),
    ];

    return ListView(
      children: [
        for (final (num, label, step) in steps)
          _buildStepItem(num, state, label, step, theme),
        if (state.isComplete || (state.stepNumber >= 2)) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.statusGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Setup complete!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.statusGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStepItem(int num, SetupState state, String label, SetupStep step, ThemeData theme) {
    final isActive = state.step == step;
    final isComplete = state.stepNumber > step.index + 1 || state.isComplete;
    final hasError = state.hasError && state.step == step;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isComplete 
                  ? AppColors.statusGreen 
                  : (isActive ? AppColors.accent : (hasError ? AppColors.statusRed : theme.colorScheme.surfaceContainerHighest)),
            ),
            child: Center(
              child: isComplete 
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '$num',
                      style: TextStyle(
                        color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: hasError ? AppColors.statusRed : null,
                  ),
                ),
                if (isActive && state.progress != null) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: state.progress! / 100),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToTerminal(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const TerminalScreen(),
      ),
    );
  }
}
