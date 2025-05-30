import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> with TickerProviderStateMixin {
  bool _isVoting = false;
  bool _isAddingBook = false;
  Set<String> _votedBooks = {};
  late AnimationController _animationController;

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _loadVotedBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadVotedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final votedBooksJson = prefs.getStringList('voted_books') ?? [];
    setState(() {
      _votedBooks = Set<String>.from(votedBooksJson);
    });
  }

  Future<void> _saveVotedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('voted_books', _votedBooks.toList());
  }

  Future<void> addSampleBooks() async {
    setState(() {
      _isAddingBook = true;
    });

    try {
      final booksCollection = FirebaseFirestore.instance.collection('books');

      final sampleBooks = [
        {
          'title': 'Гибкое сознание',
          'author': 'Кэрол Дуэк',
          'image': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&h=400&fit=crop',
          'description': 'Новый взгляд на психологию развития взрослых и детей',
          'votes': 0,
        },
        {
          'title': 'Пес по имени Мани',
          'author': 'Бодо Фешер',
          'image': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=300&h=400&fit=crop',
          'description': 'Самая известная в мире книга о финансах «Пёс по имени Мани» издана более чем в 3 миллионах экземпляров.',
          'votes': 0,
        },
        {
          'title': 'Кафе на краю земли',
          'author': 'Стрелеки Дж. П.',
          'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=400&fit=crop',
          'description': 'Как перестать плыть по течению и вспомнить, зачем ты живешь',
          'votes': 0,
        },
      ];

      for (final book in sampleBooks) {
        await booksCollection.add(book);
      }

      if (mounted) {
        _showSnackBar('Sample books added successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to add sample books: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingBook = false;
        });
      }
    }
  }

  Future<void> addNewBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      _showSnackBar('Title and author are required', Colors.orange);
      return;
    }

    setState(() {
      _isAddingBook = true;
    });

    try {
      final booksCollection = FirebaseFirestore.instance.collection('books');

      await booksCollection.add({
        'title': _titleController.text,
        'author': _authorController.text,
        'image': _imageUrlController.text,
        'description': _descriptionController.text,
        'votes': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _authorController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();

      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('Book added successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to add book: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingBook = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green
                  ? Icons.check_circle
                  : color == Colors.red
                      ? Icons.error
                      : Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showAddBookDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.menu_book,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Add New Book'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_titleController, 'Title *', Icons.title),
              const SizedBox(height: 16),
              _buildTextField(_authorController, 'Author *', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(_imageUrlController, 'Image URL', Icons.image,
                  hintText: 'https://example.com/image.jpg'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description', Icons.description,
                  maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isAddingBook ? null : addNewBook,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isAddingBook
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add Book'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Future<void> voteForBook(String bookId) async {
    if (_isVoting || _votedBooks.contains(bookId)) {
      if (_votedBooks.contains(bookId)) {
        _showSnackBar('You have already voted for this book!', Colors.orange);
      }
      return;
    }

    setState(() {
      _isVoting = true;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('books').doc(bookId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Book does not exist!');
        }

        final currentVotes = (snapshot.data()?['votes'] ?? 0) as int;
        transaction.update(docRef, {'votes': currentVotes + 1});
      });

      setState(() {
        _votedBooks.add(bookId);
      });
      
      await _saveVotedBooks();

      if (mounted) {
        _showSnackBar('Vote recorded successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to vote: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  Widget _buildBookCard(DocumentSnapshot doc, int index) {
    final bookId = doc.id;
    final title = doc['title'] ?? 'Untitled';
    final author = doc['author'] ?? 'Unknown Author';
    final imageUrl = doc['image'] ?? '';
    final votes = (doc['votes'] ?? 0) as int;
    final description = doc['description'] ?? '';
    final hasVoted = _votedBooks.contains(bookId);

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade300,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade300,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.menu_book,
                          size: 50,
                          color: Colors.grey.shade500,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.how_to_vote, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$votes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index < 3)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildRankingBadge(index),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by $author',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: hasVoted || _isVoting
                          ? null
                          : () => voteForBook(bookId),
                      icon: Icon(
                        hasVoted ? Icons.check_circle : Icons.how_to_vote,
                        size: 18,
                      ),
                      label: Text(
                        hasVoted ? 'Voted!' : 'Vote',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasVoted
                            ? Colors.green.shade400
                            : Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: hasVoted ? 0 : 2,
                        disabledBackgroundColor: Colors.green.shade300,
                        disabledForegroundColor: Colors.white,
                      ),
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

  Widget _buildRankingBadge(int index) {
    final colors = [
      Colors.amber,
      Colors.grey.shade400,
      Colors.brown.shade400,
    ];
    
    final icons = [
      Icons.emoji_events,
      Icons.workspace_premium,
      Icons.military_tech,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors[index], colors[index].withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[index].withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[index], color: Colors.white, size: 14),
          const SizedBox(width: 2),
          Text(
            '#${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(List<DocumentSnapshot> books) {
    int votedByUserCount = books.where((doc) => _votedBooks.contains(doc.id)).length;
    int totalVotes = books.fold(0, (sum, doc) => sum + ((doc['votes'] ?? 0) as int));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.blue.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Voting Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.person, color: Colors.purple.shade400, size: 32),
                const SizedBox(height: 8),
                Text(
                  '$votedByUserCount',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Books You Voted For',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (books.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Top 3 Books',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            ...books.take(3).map((doc) {
              final title = doc['title'] ?? 'Untitled';
              final votes = (doc['votes'] ?? 0) as int;
              final percent = totalVotes == 0 ? 0.0 : votes / totalVotes;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$votes votes (${(percent * 100).toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddBookDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .orderBy('votes', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading books...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final books = snapshot.data?.docs ?? [];

          if (books.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No books to vote for yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to add some books!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isAddingBook ? null : addSampleBooks,
                      icon: _isAddingBook
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.library_books),
                      label: Text(_isAddingBook ? 'Adding...' : 'Add Sample Books'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: showAddBookDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your Own Book'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Books to Vote',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 380,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    index * 0.1,
                                    1.0,
                                    curve: Curves.easeOutCubic,
                                  ),
                                )),
                                child: FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      index * 0.1,
                                      1.0,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                  child: _buildBookCard(books[index], index),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStatisticsCard(books),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}