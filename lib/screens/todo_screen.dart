// ignore_for_file: unused_field, prefer_const_constructors

import 'dart:ui' as ui; // <-- alias dart:ui to use ui.ImageFilter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/todo_model.dart';
import '../widgets/todo_item.dart';

/// Spotify-premium inspired Todo screen (v2)
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Palette
  static const _bgStart = Color(0xFF0E0E0E);
  static const _bgEnd = Color(0xFF181818);
  static const _surface = Color(0xFF1C1C1C);
  static const _surfaceHi = Color(0xFF222222);
  static const _muted = Color(0xFFB3B3B3);
  static const _accent = Color(0xFF1DB954);

  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'All'; // All | Active | Done
  int _navIndex = 0; // for the bottom nav look

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Strongly type your stream to avoid generic/runtime issues
    final Stream<QuerySnapshot<Object?>> todosStream = context
        .read<FirebaseService>()
        .getTodos();

    return Scaffold(
      backgroundColor: _bgStart,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            const Text(
              'Your Tasks',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            _PremiumBadge(),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(FontAwesomeIcons.rightFromBracket),
            color: Colors.white,
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1C1C1C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Are you sure?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Do you really want to log out?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Log out',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                context.read<FirebaseService>().signOut();
              }
            },
          ),
        ],
      ),
      floatingActionButton: _AddButton(onTap: () => _showAddTodoSheet(context)),
      bottomNavigationBar: _SpotifyBottomNav(
        index: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgStart, _bgEnd],
          ),
        ),
        child: Stack(
          children: [
            // Subtle ambient glows
            Positioned(
              top: -60,
              left: -40,
              child: _GlowBlob(
                size: 220,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: _GlowBlob(
                size: 260,
                color: Colors.white.withOpacity(0.04),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting + quick add
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (rect) => const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(rect),
                                child: const Text(
                                  'Good evening',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Let's get a few things done",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.72),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _showAddTodoSheet(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: const ui.Color.fromRGBO(
                              29,
                              185,
                              84,
                              1,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text(
                            'Quick add',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _DarkSearchField(
                      controller: _searchCtrl,
                      hint: 'Search tasks',
                      onChanged: (v) =>
                          setState(() => _query = v.trim().toLowerCase()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stat capsules ("Made For You" style)
                  StreamBuilder<QuerySnapshot<Object?>>(
                    stream: todosStream,
                    builder: (context, snap) {
                      final docs = snap.data?.docs ?? const [];
                      final todos = docs
                          .map((d) => Todo.fromFirestore(d))
                          .whereType<Todo>()
                          .toList();

                      final total = todos.length;
                      final done = todos.where((t) => t.isDone == true).length;
                      final active = total - done;

                      return _StatCapsules(
                        total: total,
                        active: active,
                        done: done,
                        onTapAll: () {
                          HapticFeedback.selectionClick();
                          setState(() => _filter = 'All');
                        },
                        onTapActive: () {
                          HapticFeedback.selectionClick();
                          setState(() => _filter = 'Active');
                        },
                        onTapDone: () {
                          HapticFeedback.selectionClick();
                          setState(() => _filter = 'Done');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Filter chips (All / Active / Done)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      children: [
                        const SizedBox(width: 4),
                        for (final f in const ['All', 'Active', 'Done'])
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: _filter == f,
                              onSelected: (_) {
                                HapticFeedback.selectionClick();
                                setState(() => _filter = f);
                              },
                              labelStyle: TextStyle(
                                color: _filter == f
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              backgroundColor: const Color(0xFF2A2A2A),
                              selectedColor: _accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: _filter == f
                                      ? _accent
                                      : Colors.white.withOpacity(0.10),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // List surface (glass)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _surface.withOpacity(0.88),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 24,
                                offset: const Offset(0, -8),
                              ),
                            ],
                          ),
                          child: StreamBuilder<QuerySnapshot<Object?>>(
                            stream: todosStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const _CenteredMessage(
                                  icon: Icons.error_outline,
                                  title: 'Something went wrong',
                                  subtitle: 'Please try again shortly.',
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const _LoadingListSkeleton();
                              }

                              final docs = snapshot.data?.docs ?? [];
                              final todos = docs
                                  .map((d) => Todo.fromFirestore(d))
                                  .whereType<Todo>()
                                  .toList();

                              // helpers (typed)
                              bool isDone(Todo t) => t.isDone == true;
                              String titleOf(Todo t) => (t.title).toString();

                              final filtered = todos.where((t) {
                                final matchesQuery =
                                    _query.isEmpty ||
                                    titleOf(t).toLowerCase().contains(_query);
                                final matchesFilter = _filter == 'All'
                                    ? true
                                    : _filter == 'Active'
                                    ? !isDone(t)
                                    : isDone(t);
                                return matchesQuery && matchesFilter;
                              }).toList();

                              if (filtered.isEmpty) {
                                return const _CenteredMessage(
                                  icon: Icons.inbox_outlined,
                                  title: 'No matching tasks',
                                  subtitle:
                                      'Try a different keyword or filter.',
                                );
                              }

                              return Stack(
                                children: [
                                  RefreshIndicator(
                                    color: _accent,
                                    onRefresh: () async {
                                      // Firestore streams update automatically; fake a short refresh delay for UX polish.
                                      await Future<void>.delayed(
                                        const Duration(milliseconds: 600),
                                      );
                                    },
                                    child: ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        10,
                                        10,
                                        160, // leave room for mini player
                                      ),
                                      physics: const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final todo = filtered[index];
                                        return _SpotifyTileSurface(
                                          child: TodoItem(todo: todo),
                                        );
                                      },
                                    ),
                                  ),

                                  // Faux Spotify mini player (summary)
                                  Positioned(
                                    left: 14,
                                    right: 14,
                                    bottom: 76,
                                    child: _MiniPlayerBar(
                                      activeCount: todos
                                          .where((t) => !isDone(t))
                                          .length,
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        setState(() => _filter = 'Active');
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
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

  void _showAddTodoSheet(BuildContext context) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _DarkBottomSheet(
          child: Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom: 18 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.add_task_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Add New Todo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _DarkTextField(
                  controller: textController,
                  hint: 'Enter todo title',
                  onSubmitted: (_) => _submitNewTodo(context, textController),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () => _submitNewTodo(context, textController),
                    child: const Text(
                      'Add Todo',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitNewTodo(
    BuildContext context,
    TextEditingController ctrl,
  ) async {
    final title = ctrl.text.trim();
    if (title.isEmpty) return;
    await context.read<FirebaseService>().addTodo(title);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }
}

// ---------- widgets ----------

class _AddButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});
  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.99,
        end: 1.15,
      ).chain(CurveTween(curve: Curves.easeInOut)).animate(_c),
      child: FloatingActionButton.extended(
        backgroundColor: const ui.Color.fromRGBO(29, 185, 84, 1),
        foregroundColor: const ui.Color.fromRGBO(29, 185, 84, 1),
        onPressed: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
        elevation: 3,
      ),
    );
  }
}

class _SpotifyBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _SpotifyBottomNav({required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: onTap,
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_rounded),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const _DarkSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  @override
  State<_DarkSearchField> createState() => _DarkSearchFieldState();
}

class _DarkSearchFieldState extends State<_DarkSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.85)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                border: InputBorder.none,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: widget.controller.text.isNotEmpty ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                widget.controller.clear();
                widget.onChanged('');
              },
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              tooltip: 'Clear',
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotifyTileSurface extends StatelessWidget {
  final Widget child;
  const _SpotifyTileSurface({required this.child});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LoadingListSkeleton extends StatelessWidget {
  const _LoadingListSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _SkeletonTile(),
    );
  }
}

class _SkeletonTile extends StatefulWidget {
  const _SkeletonTile();
  @override
  State<_SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<_SkeletonTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _CenteredMessage({
    required this.icon,
    required this.title,
    this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.white.withOpacity(0.95)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.72)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DarkBottomSheet extends StatelessWidget {
  final Widget child;
  const _DarkBottomSheet({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF202020).withOpacity(0.92),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  const _DarkTextField({
    required this.controller,
    required this.hint,
    this.onSubmitted,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      textInputAction: TextInputAction.done,
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size / 2.3,
              spreadRadius: size / 7,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF333333)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.crown,
            size: 12,
            color: ui.Color.fromARGB(255, 228, 186, 1),
          ),
          SizedBox(width: 6),
          Text(
            'Premium',
            style: TextStyle(
              color: ui.Color.fromARGB(255, 228, 186, 2),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCapsules extends StatelessWidget {
  final int total;
  final int active;
  final int done;
  final VoidCallback onTapAll;
  final VoidCallback onTapActive;
  final VoidCallback onTapDone;
  const _StatCapsules({
    required this.total,
    required this.active,
    required this.done,
    required this.onTapAll,
    required this.onTapActive,
    required this.onTapDone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _Capsule(
            title: 'All Tasks',
            value: total,
            icon: FontAwesomeIcons.listCheck,
            onTap: onTapAll,
          ),
          _Capsule(
            title: 'Active',
            value: active,
            icon: FontAwesomeIcons.bolt,
            onTap: onTapActive,
          ),
          _Capsule(
            title: 'Done',
            value: done,
            icon: FontAwesomeIcons.check,
            onTap: onTapDone,
          ),
        ],
      ),
    );
  }
}

class _Capsule extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final VoidCallback onTap;
  const _Capsule({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF242424), Color(0xFF1E1E1E)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.84),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$value items',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;
  const _MiniPlayerBar({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F1F1F), Color(0xFF151515)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            // Circular progress vibe
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFF1DB954),
                    Color(0xFF1DB954),
                    Color(0xFF101010),
                  ],
                  stops: [0.0, 0.7, 0.7],
                ),
              ),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Focus queue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '$activeCount active tasks',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const ui.Color.fromARGB(
                  255,
                  70,
                  252,
                  70,
                ).withOpacity(0.00),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const ui.Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withOpacity(0.06),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: const [
                  Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
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
