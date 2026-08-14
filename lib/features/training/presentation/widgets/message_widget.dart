import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:dialog_feedback/core/utils/logger.dart';
import 'package:dialog_feedback/features/training/domain/entities/message.dart';
import 'package:dialog_feedback/features/training/domain/entities/message_role.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.autoPlay,
  });

  final Message message;
  final bool autoPlay;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: switch (message.role) {
        MessageRole.user => Theme.of(context).colorScheme.primaryFixedDim,
        MessageRole.ai => Colors.transparent,
      },
      child: FractionallySizedBox(
        widthFactor: 0.7,
        alignment: switch (message.role) {
          MessageRole.user => .centerRight,
          MessageRole.ai => .centerLeft,
        },
        child: Padding(
          padding: .all(8.0),
          child: Column(
            spacing: 4,
            mainAxisSize: .min,
            crossAxisAlignment: switch (message.role) {
              MessageRole.user => .start,
              MessageRole.ai => .end,
            },
            children: [
              SelectableText(message.messageText),
              Text(
                message.createdAt.toIso8601String(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              if (message.audioPath.isNotEmpty)
                _AudioButton(audioPath: message.audioPath, autoPlay: autoPlay),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioButton extends StatefulWidget {
  const _AudioButton({required this.audioPath, required this.autoPlay});

  final String audioPath;
  final bool autoPlay;

  @override
  State<_AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<_AudioButton> {
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _stateSubscription;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _stateSubscription = _player.onPlayerStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant _AudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPath != widget.audioPath) {
      _initPlayer();
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    if (widget.audioPath.isEmpty) return;
    try {
      _hasError = false;
      if (widget.autoPlay) {
        await _player.play(DeviceFileSource(widget.audioPath));
      } else {
        await _player.setSourceDeviceFile(widget.audioPath);
      }
    } catch (e) {
      glog.e(e);
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  String _getText() {
    if (_hasError) return "Audio Error".hc;
    return switch (_player.state) {
      PlayerState.completed ||
      PlayerState.stopped ||
      PlayerState.paused => "Play".hc,
      PlayerState.playing => "Stop".hc,
      PlayerState.disposed => "Audio Error".hc,
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (_hasError) return;
        try {
          switch (_player.state) {
            case PlayerState.playing:
              await _player.pause();
              await _player.seek(Duration.zero);
              break;
            case PlayerState.paused:
              await _player.resume();
              break;
            case PlayerState.completed:
            case PlayerState.stopped:
              await _player.play(DeviceFileSource(widget.audioPath));
              break;
            case PlayerState.disposed:
              break;
          }
        } catch (e) {
          glog.e(e);
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        }
      },
      child: Text(
        _getText(),
        style: TextStyle(color: Theme.of(context).primaryColor.hc),
      ),
    );
  }
}
