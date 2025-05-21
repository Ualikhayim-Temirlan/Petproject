import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final int maxTeamMembers = 3;
  String? _errorMessage;
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
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
                      border: OutlineInputBorder(),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
              stream: FirebaseFirestore.instance.collection('teams').orderBy('createdAt', descending: true).snapshots(),
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

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          data['name'] ?? 'Unnamed Team',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                                onPressed: (_isLoading || teamIsFull)
                                    ? null
                                    : () => joinTeam(team),
                                child: Text(teamIsFull ? 'Full' : 'Join'),
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }
}