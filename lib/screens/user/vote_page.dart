import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  bool _isVoting = false;
  bool _isAddingBook = false;
  final Map<String, bool> _votedBooks = {};

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          'image':
              'lib/assets/book1.png',
          'description': 'Новый взгляд на психологию развития взрослых и детей',
          'votes': 0,
        },
        {
          'title': 'Пес по имени Мани',
          'author': 'Бодо Фешер',
          'image':
              'lib/assets/book2.png',
          'description':
              'Самая известная в мире книга о финансах «Пёс по имени Мани» издана более чем в 3 миллионах экземпляров.',
          'votes': 0,
        },
        {
          'title': 'Кафе на краю земли',
          'author': 'Стрелеки Дж. П.',
          'image':
              'lib/assets/book3.png',
          'description':
              'Как перестать плыть по течению и вспомнить, зачем ты живешь',
          'votes': 0,
        },
      ];

      for (final book in sampleBooks) {
        await booksCollection.add(book);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample books added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add sample books: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and author are required'),
          backgroundColor: Colors.red,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingBook = false;
        });
      }
    }
  }

  void showAddBookDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Add New Book'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(
                      labelText: 'Author *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com/image.jpg',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
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
                child:
                    _isAddingBook
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

  Future<void> voteForBook(String bookId) async {
    if (_isVoting) return;

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
        _votedBooks[bookId] = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote recorded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to vote: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Voting'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddBookDialog,
            tooltip: 'Add new book',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('books')
                .orderBy('votes', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final books = snapshot.data?.docs ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No books found for voting.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isAddingBook ? null : addSampleBooks,
                    icon:
                        _isAddingBook
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.library_books),
                    label: Text(
                      _isAddingBook ? 'Adding...' : 'Add Sample Books',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: showAddBookDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your Own Book'),
                  ),
                ],
              ),
            );
          }
          int totalVotes = books.fold(0, (sum, doc) {
            final votes = (doc['votes'] ?? 0) as int;
            return sum + votes;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final doc = books[index];
              final bookId = doc.id;
              final title = doc['title'] ?? 'Untitled';
              final author = doc['author'] ?? 'Unknown Author';
              final imageUrl = doc['image'] ?? '';
              final votes = (doc['votes'] ?? 0) as int;
              final description = doc['description'] ?? '';
              final percent = totalVotes == 0 ? 0.0 : votes / totalVotes;
              final hasVoted = _votedBooks[bookId] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, _, __) => Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.how_to_vote,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$votes',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'by $author',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (index < 3) 
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        [
                                          Colors.amber,
                                          Colors.grey.shade300,
                                          Colors.brown.shade300,
                                        ][index],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '#${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(color: Colors.grey.shade800),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        minHeight: 10,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              percent > 0.5
                                                  ? Colors.green
                                                  : Colors.blue,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${(percent * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      hasVoted || _isVoting
                                          ? null
                                          : () => voteForBook(bookId),
                                  icon: Icon(
                                    hasVoted
                                        ? Icons.check_circle
                                        : Icons.how_to_vote,
                                  ),
                                  label: Text(hasVoted ? 'Voted' : 'Vote Now'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    disabledBackgroundColor: Colors.green
                                        .withOpacity(0.3),
                                    disabledForegroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}