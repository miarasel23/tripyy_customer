import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/app_urls.dart';
import '../controller/chat_bloc.dart';
import '../controller/chat_event.dart';
import '../controller/chat_state.dart';
import '../model/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final String customerUuid;
  final String driverUuid;
  final String receiverType; // 'DRIVER' or 'ADMIN'
  final String title;

  const ChatScreen({
    super.key,
    required this.customerUuid,
    this.driverUuid = '',
    this.receiverType = 'DRIVER',
    this.title = 'Chat',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final chatBloc = context.read<ChatBloc>();
    chatBloc.add(FetchMessages(
      customerUuid: widget.customerUuid,
      driverUuid: widget.driverUuid,
      receiverType: widget.receiverType,
    ));
    chatBloc.startPolling(
      widget.customerUuid,
      driverUuid: widget.driverUuid,
      receiverType: widget.receiverType,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    context.read<ChatBloc>().add(SendMessage(
          customerUuid: widget.customerUuid,
          driverUuid: widget.driverUuid,
          message: text,
          receiverType: widget.receiverType,
        ));
  }

  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null && mounted) {
      context.read<ChatBloc>().add(SendMessage(
            customerUuid: widget.customerUuid,
            driverUuid: widget.driverUuid,
            message: '',
            receiverType: widget.receiverType,
            filePath: image.path,
          ));
    }
  }

  String _formatTime(String createdAt) {
    if (createdAt.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatError) {
                  return Center(child: Text(state.error));
                } else if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text("No messages yet. Say hi!"),
                    );
                  }

                  final reversedMessages = state.messages.reversed.toList();

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: reversedMessages.length,
                    itemBuilder: (context, index) {
                      final message = reversedMessages[index];
                      final isMe = message.senderType == 'CUSTOMER';

                      return _buildMessageBubble(message, isMe, theme);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  String _getImageUrl(String fileUrl) {
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    }
    return fileUrl.startsWith('/') ? '${AppUrls.baseUrl}$fileUrl' : '${AppUrls.baseUrl}/$fileUrl';
  }

  void _showFullImageDialog(String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                      errorBuilder: (context, error, stackTrace) => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: Colors.white54, size: 60),
                          SizedBox(height: 8),
                          Text("Unable to load image", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isMe, ThemeData theme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.fileUrl != null && message.fileUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () => _showFullImageDialog(_getImageUrl(message.fileUrl!)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 200,
                        maxHeight: 180,
                      ),
                      child: Image.network(
                        _getImageUrl(message.fileUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 90,
                          width: 140,
                          color: Colors.black12,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey, size: 24),
                              SizedBox(height: 4),
                              Text("Image not found", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (message.message.isNotEmpty)
              Text(
                message.message,
                style: TextStyle(
                  color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: isMe ? theme.colorScheme.onPrimary.withValues(alpha: 0.7) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.check,
                    size: 14,
                    color: message.isRead ? Colors.lightBlueAccent : theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: theme.colorScheme.primary),
              onPressed: _pickAndSendImage,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final isSending = state is ChatLoaded && state.isSending;
                return isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: Icon(Icons.send, color: theme.colorScheme.primary),
                        onPressed: _sendMessage,
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
