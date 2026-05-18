class BookingState {
  static bool jobStarted = false;
  static bool technicianArrived = false;

  static final List<Map<String, dynamic>> customerMessages = [
    {'sender': 'Ali Raza', 'message': 'Assalam-o-Alaikum! I am Ali, your matched technician. I am packing my tools and heading to your location now.', 'isMe': false, 'time': '08:30 AM'},
    {'sender': 'You', 'message': 'Walaikum Assalam! Great, thank you. The main gate will be open, second floor.', 'isMe': true, 'time': '08:32 AM'},
    {'sender': 'Ali Raza', 'message': 'Understood, see you soon! 👍', 'isMe': false, 'time': '08:33 AM'},
  ];

  static final List<Map<String, dynamic>> technicianMessages = [
    {'sender': 'Sara Ahmed', 'message': 'Hi! Are you on your way?', 'isMe': false, 'time': '11:30 AM'},
    {'sender': 'You', 'message': 'Yes, I am heading to your location now. ETA 8 minutes.', 'isMe': true, 'time': '11:31 AM'},
    {'sender': 'Sara Ahmed', 'message': 'Great! The main gate will be open. Please come to the second floor.', 'isMe': false, 'time': '11:32 AM'},
    {'sender': 'You', 'message': 'Understood, see you soon! 👍', 'isMe': true, 'time': '11:33 AM'},
  ];
}
