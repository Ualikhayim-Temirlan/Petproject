import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> with SingleTickerProviderStateMixin {
  final TextEditingController _teamNameController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final int maxTeamMembers = 3;
  String? _errorMessage;
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Check if user is already in a team
  Future<bool> isUserInAnyTeam() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('members', arrayContains: uid)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user team status: $e');
      return false;
    }
  }

  Future<void> createTeam(String name) async {
    if (name.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a team name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if user is already in a team
      bool alreadyInTeam = await isUserInAnyTeam();
      if (alreadyInTeam) {
        setState(() {
          _errorMessage = 'You can only be in one team at a time. Please leave your current team first.';
        });
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      String? currentUserName = currentUser?.displayName ?? 'Anonymous User';
      await FirebaseFirestore.instance.collection('teams').add({
        'name': name,
        'members': [uid],
        'memberNames': [{
          'uid': uid,
          'name': currentUserName,
        }],
        'createdAt': FieldValue.serverTimestamp(),
        'points': 0, // Initialize points for leaderboard
      });

      _teamNameController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create team: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> joinTeam(DocumentSnapshot team) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if user is already in a team
      bool alreadyInTeam = await isUserInAnyTeam();
      if (alreadyInTeam) {
        setState(() {
          _errorMessage = 'You can only be in one team at a time. Please leave your current team first.';
        });
        return;
      }

      final List<dynamic> members = team['members'] ?? [];
      
      if (members.length >= maxTeamMembers) {
        setState(() {
          _errorMessage = 'This team has reached the maximum of $maxTeamMembers members';
        });
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      String? currentUserName = currentUser?.displayName ?? 'Anonymous User';

      await FirebaseFirestore.instance.collection('teams').doc(team.id).update({
        'members': FieldValue.arrayUnion([uid]),
        'memberNames': FieldValue.arrayUnion([{
          'uid': uid,
          'name': currentUserName,
        }]),
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to join team: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> leaveTeam(DocumentSnapshot team) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> memberNames = team['memberNames'] ?? [];
      final memberNameToRemove = memberNames.firstWhere(
        (member) => member['uid'] == uid,
        orElse: () => null,
      );

      await FirebaseFirestore.instance.collection('teams').doc(team.id).update({
        'members': FieldValue.arrayRemove([uid]),
        'memberNames': FieldValue.arrayRemove([memberNameToRemove]),
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to leave team: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLeaderboard() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('teams')
          .orderBy('points', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No teams in leaderboard yet'),
              ],
            ),
          );
        }

        final teams = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            final Map<String, dynamic> data = team.data() as Map<String, dynamic>;
            final List<dynamic> members = data['members'] ?? [];
            final int points = data['points'] ?? 0;
            final bool isMyTeam = members.contains(uid);

            Widget? leadingIcon;
            Color? backgroundColor;
            if (index == 0) {
              leadingIcon = const Icon(Icons.emoji_events, color: Colors.amber, size: 32);
              backgroundColor = Colors.amber.withOpacity(0.1);
            } else if (index == 1) {
              leadingIcon = const Icon(Icons.emoji_events, color: Colors.grey, size: 28);
              backgroundColor = Colors.grey.withOpacity(0.1);
            } else if (index == 2) {
              leadingIcon = const Icon(Icons.emoji_events, color: Colors.orange, size: 24);
              backgroundColor = Colors.orange.withOpacity(0.1);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: isMyTeam
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                    : null,
              ),
              child: ListTile(
                leading: leadingIcon ?? CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['name'] ?? 'Unnamed Team',
                        style: TextStyle(
                          fontWeight: isMyTeam ? FontWeight.bold : FontWeight.w500,
                          color: isMyTeam ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                    ),
                    if (isMyTeam)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'MY TEAM',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text('${members.length} members'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$points',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'points',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeamsList() {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a New Team',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _teamNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter team name',
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => createTeam(_teamNameController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Create Team'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('teams')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No teams available'));
              }

              final teams = snapshot.data!.docs;
              return FutureBuilder<bool>(
                future: isUserInAnyTeam(),
                builder: (context, userTeamSnapshot) {
                  final bool userAlreadyInTeam = userTeamSnapshot.data ?? false;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final Map<String, dynamic> data = team.data() as Map<String, dynamic>;
                      
                      final List<dynamic> members = data['members'] ?? [];
                      final List<dynamic> memberNames = data['memberNames'] ?? [];
                      final bool joined = members.contains(uid);
                      final bool teamIsFull = members.length >= maxTeamMembers;
                      final int points = data['points'] ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['name'] ?? 'Unnamed Team',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$points pts',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text('${members.length}/$maxTeamMembers members'),
                          trailing: joined
                              ? ElevatedButton(
                                  onPressed: _isLoading ? null : () => leaveTeam(team),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[100],
                                    foregroundColor: Colors.red[900],
                                  ),
                                  child: const Text('Leave'),
                                )
                              : ElevatedButton(
                                  onPressed: (_isLoading || teamIsFull || (userAlreadyInTeam && !joined))
                                      ? null
                                      : () => joinTeam(team),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    teamIsFull 
                                        ? 'Full' 
                                        : (userAlreadyInTeam && !joined)
                                            ? 'Already in team'
                                            : 'Join'
                                  ),
                                ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Team Members:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...memberNames.map((member) {
                                    final bool isCurrentUser = member['uid'] == uid;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            member['name'] ?? 'Unknown User',
                                            style: TextStyle(
                                              fontWeight: isCurrentUser
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isCurrentUser
                                                  ? Theme.of(context).colorScheme.primary
                                                  : null,
                                            ),
                                          ),
                                          if (isCurrentUser)
                                            const Text(' (You)'),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  if (memberNames.isEmpty)
                                    const Text('No members yet'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.groups),
              text: 'All Teams',
            ),
            Tab(
              icon: Icon(Icons.leaderboard),
              text: 'Leaderboard',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTeamsList(),
          _buildLeaderboard(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}