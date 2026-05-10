import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car_model.dart';
import '../models/inquiry_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

class ChatScreen extends StatefulWidget {
  final int inquiryId;

  const ChatScreen({super.key, required this.inquiryId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  List<Message> _messages = [];
  bool _isSending = false;
  int _currentUserId = 0;
  Inquiry? _inquiry;
  Car? _car;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadInquiryAndCar();
    if (!mounted) return;
    await _loadMessages();
    if (!mounted) return;
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _loadMessages(silent: true),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? prefs.getInt('seller_id') ?? 0;
    if (!mounted) return;
    setState(() => _currentUserId = userId);
  }

  Future<void> _loadInquiryAndCar() async {
    try {
      final inquiry = await ApiService().getInquiryDetails(widget.inquiryId);
      if (!mounted) return;

      setState(() {
        _inquiry = inquiry;
      });

      if (inquiry != null) {
        final car = await ApiService().getCarById(inquiry.vehicleId);
        if (!mounted) return;

        if (car != null) {
          setState(() {
            _car = car;
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Load inquiry/car error: $e');
    }
  }

  Future<void> _loadMessages({bool silent = false}) async {
    try {
      final response = await ApiService().fetchMessages(widget.inquiryId);
      if (!mounted) return;

      // Create a synthetic message for the initial inquiry if we have inquiry details
      final allMessages = <Message>[];

      if (_inquiry != null) {
        // Parse the date string to DateTime
        DateTime inquiryDate;
        try {
          inquiryDate = DateTime.parse(_inquiry!.date);
        } catch (e) {
          inquiryDate = DateTime.now();
        }

        // Add the initial inquiry message as the first message
        final inquiryMessage = Message(
          id: -1, // Negative ID to indicate it's the inquiry message, not from DB
          inquiryId: widget.inquiryId,
          senderId: _inquiry!.buyerId,
          messageText: _inquiry!.message,
          sentAt: inquiryDate,
        );
        allMessages.add(inquiryMessage);
      }

      // Add all other messages
      allMessages.addAll(response);

      setState(() {
        _messages = allMessages;
      });

      if (!silent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Load messages error: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending || _currentUserId <= 0) return;

    setState(() => _isSending = true);

    final success = await ApiService().sendMessage(
      inquiryId: widget.inquiryId,
      senderId: _currentUserId,
      messageText: text,
    );

    if (!mounted) return;

    setState(() => _isSending = false);

    if (success) {
      _messageController.clear();
      await _loadMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String carName = _car?.make != null && _car?.model != null
        ? '${_car!.make} ${_car!.model}'
        : _inquiry?.carName ?? 'Chat';

    String? carImage;
    if (_car != null && _car!.image.isNotEmpty) {
      carImage = _car!.image;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: GestureDetector(
          onTap: _car != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarDetailsScreen(car: _car!),
                    ),
                  );
                }
              : null,
          child: Row(
            children: [
              if (carImage != null && carImage.isNotEmpty)
                Container(
                  width: 45,
                  height: 45,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(carImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 45,
                  height: 45,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.directions_car,
                    color: const Color(0xFF00F5FF),
                    size: 24,
                  ),
                ),
              Expanded(
                child: Text(
                  carName,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMine = message.senderId == _currentUserId;
                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMine
                                ? Colors.cyanAccent.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isMine
                                  ? Colors.cyanAccent.withValues(alpha: 0.35)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.messageText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                message.sentAt.toString(),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _isSending ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
