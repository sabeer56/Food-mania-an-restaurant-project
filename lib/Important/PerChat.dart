import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PersonalChat extends StatefulWidget {
  @override
  PersonalChatScreen createState() => PersonalChatScreen();
}

class PersonalChatScreen extends State<PersonalChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [
    Message(isSender: true, message: 'Good Morning!', time: '10:00 am'),
    Message(isSender: false, message: 'Good Morning!', time: '10:01 am'),
    Message(isSender: true, message: 'Epdi Iruka', time: '10:02 am'),
    Message(isSender: false, message: 'Nalla Irukeyn..!', time: '10:03 am'),
    Message(isSender: true, message: 'Enna panra', time: '10:03 am'),
    Message(isSender: false, message: 'Saaptutu Irukeyn', time: '10:04 am'),
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(
          Message(isSender: true, message: _controller.text, time: _formatCurrentTime()),
        );
        _controller.clear(); // Clear the text field after sending the message
      });
    }
  }

  // Replacing the default AlertDialog with a custom-positioned dialog for Info icon
  void _showPersonSettings(BuildContext context, String personName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 60,
              right: 50,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: 185, // Customize width as per need
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Info',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Name', style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          _showEditDialog(context, 'Edit Name');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Delete Chat', style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          _deleteChat();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // New: Custom dialog for more_vert (ellipsis) icon
  void _showMoreOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 60,
              right: 10, // Position this relative to the ellipsis icon
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: 185, // Customize width as per need
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Options',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings', style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          // Handle settings logic
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.block),
                        title: const Text('Block', style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          // Handle block logic
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout', style: TextStyle(fontSize: 12)),
                        onTap: () {
                          Navigator.pop(context);
                          // Handle logout logic
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteChat() {
    setState(() {
      _messages.clear(); // This will remove all messages from the list
    });
  }

  void _showEditDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _editController = TextEditingController();
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              hintText: title == 'Edit Name' ? 'Enter new name' : 'Enter new message',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement saving the new name or message
                Navigator.pop(context);
                // You might want to update the name or message here
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.userCircle, size: isSmallScreen ? 20 : 30),
            SizedBox(width: 10),
            Text('Online', style: TextStyle(fontSize: isSmallScreen ? 16 : 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            color: Colors.teal[800],
            onPressed: () {
              _showPersonSettings(context, 'Person Name'); // Replace with actual person name if available
            },
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.ellipsisVertical, size: isSmallScreen ? 20 : 30),
            onPressed: () {
              _showMoreOptionsDialog(context); // Open the new dialog for more options
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(
                    isSender: message.isSender,
                    message: message.message,
                    time: message.time,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(139, 0, 0, 0),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Write a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isSender;
  final String message;
  final String time;

  ChatBubble({required this.isSender, required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var isSmallScreen = screenSize.width < 600;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: isSender ? Colors.teal[200] : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: isSender ? Radius.circular(20) : Radius.circular(0),
                  topRight: isSender ? Radius.circular(0) : Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: isSender ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isSender;
  final String message;
  final String time;

  Message({required this.isSender, required this.message, required this.time});
}
