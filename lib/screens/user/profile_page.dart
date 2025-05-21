import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = {
      'name': 'Tima',
      'email': 'tima@gmail.com',
      'bio': 'Flutter developer passionate about creating beautiful UIs and smooth user experiences.',
      'votesCast': 2,
      'teamsJoined': 1,
      'joinDate': 'May 10, 2025',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile clicked')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, userData),
            
            _buildInfoSection(userData),
            
            _buildStatsSection(userData),
            
            _buildAccountSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(userData['name']),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
                    Text(
            userData['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
                    Text(
            userData['email'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> userData) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'About Me',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              userData['bio'],
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> userData) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  Icons.how_to_vote,
                  userData['votesCast'].toString(),
                  'Votes Cast',
                  Colors.purple,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  Icons.group,
                  userData['teamsJoined'].toString(),
                  'Teams',
                  Colors.blue,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  Icons.calendar_today,
                  userData['joinDate'],
                  'Joined',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildSettingsItem(
              context,
              Icons.notifications_active,
              'Notifications',
              'Set your notification preferences',
              Colors.amber,
            ),
            _buildSettingsItem(
              context,
              Icons.security,
              'Security',
              'Change password and security settings',
              Colors.green,
            ),
            _buildSettingsItem(
              context,
              Icons.support_agent,
              'Help & Support',
              'Get help or contact support',
              Colors.blue,
            ),
            _buildSettingsItem(
              context,
              Icons.logout,
              'Sign Out',
              'Sign out of your account',
              Colors.red,
              isSignOut: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    bool isSignOut = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSignOut ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title clicked')),
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    
    return '?';
  }
}