import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:unicons/unicons.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;

  const CategoryScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadRecipes(context),
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScaffold(context);
        }

        // Error State
        if (snapshot.hasError) {
          return _buildErrorScaffold(context, snapshot.error.toString());
        }

        // Success State
        return Consumer<ListOfRecipes>(
          builder: (context, recipesProvider, child) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F5F5),
              body: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildModernAppBar(context),
                    _buildCategoryStats(context, recipesProvider),
                    CategoryRecipesList(categoryName: categoryName),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Modern App Bar with gradient and animations
  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(50),
            splashColor: const Color(0xfffe0000).withOpacity(0.2),
            highlightColor: const Color(0xfffe0000).withOpacity(0.1),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xfffe0000).withOpacity(0.15),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xfffe0000).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xfffe0000),
                size: 20,
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xfffe0000),
                Color(0xffff3333),
                Color(0xffff5555),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated decorative shapes
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: DotPatternPainter(),
                ),
              ),
              // Category title with enhanced typography
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            UniconsLine.layer_group,
                            size: 14,
                            color: Colors.white.withOpacity(0.95),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CATEGORY',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFE5E5)],
                      ).createShader(bounds),
                      child: Text(
                        categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xfffe0000).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xfffe0000).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Text(
            categoryName,
            style: const TextStyle(
              color: Color(0xfffe0000),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced category statistics
  Widget _buildCategoryStats(BuildContext context, ListOfRecipes provider) {
    final recipeCount = provider.findByCategory(categoryName).length;
    final totalTime = provider.findByCategory(categoryName).fold<double>(
          0,
          (sum, recipe) => sum + recipe.prepTime + recipe.cookTime,
        );
    final avgTime = recipeCount > 0 ? (totalTime / recipeCount) : 0;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xfffe0000).withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xfffe0000).withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xfffe0000).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xfffe0000),
                          Color(0xffff4444),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xfffe0000).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      UniconsLine.restaurant,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xfffe0000),
                                  Color(0xffff4444),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                '$recipeCount',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Recipes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[700],
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Available in this collection',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xfffe0000).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: UniconsLine.clock,
                      label: 'Avg Time',
                      value: '${avgTime.toStringAsFixed(0)}m',
                      color: const Color(0xffff6b6b),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xfffe0000).withOpacity(0.1),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: UniconsLine.fire,
                      label: 'Total Time',
                      value: '${totalTime.toStringAsFixed(0)}m',
                      color: const Color(0xfffe0000),
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildModernAppBar(context),
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xfffe0000)),
                      strokeWidth: 3.5,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading Recipes...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildModernAppBar(context),
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xfffe0000).withOpacity(0.12),
                              const Color(0xffff6b6b).withOpacity(0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xfffe0000).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          UniconsLine.exclamation_triangle,
                          size: 68,
                          color: Color(0xfffe0000),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Oops! Something Went Wrong',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          height: 1.5,
                          letterSpacing: -0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadRecipes(BuildContext context) async {
    final recipesProvider = Provider.of<ListOfRecipes>(context, listen: false);
    if (recipesProvider.getRecipes.isEmpty) {
      await recipesProvider.loadRecipes();
    }
  }
}

// Custom painter for dot pattern
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    for (var i = 0; i < size.width / spacing; i++) {
      for (var j = 0; j < size.height / spacing; j++) {
        canvas.drawCircle(
          Offset(i * spacing, j * spacing),
          1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CategoryRecipesList extends StatelessWidget {
  final String categoryName;

  const CategoryRecipesList({Key? key, required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ListOfRecipes>(
      builder: (context, recipesProvider, child) {
        final recipeList = recipesProvider.findByCategory(categoryName);
        final savedProvider = Provider.of<SavedProvider>(context);

        if (recipeList.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[100]!,
                          Colors.grey[50]!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      UniconsLine.restaurant,
                      size: 84,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'No Recipes Found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[700],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Try exploring other categories',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recipe = recipeList[index];
                final isSaved = savedProvider.getSaved
                    .containsKey(recipe.recipeId.toString());

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: _ModernRecipeCard(
                    recipe: recipe,
                    isSaved: isSaved,
                    savedProvider: savedProvider,
                  ),
                );
              },
              childCount: recipeList.length,
            ),
          ),
        );
      },
    );
  }
}

// Stateful widget for hover and press effects
class _ModernRecipeCard extends StatefulWidget {
  final dynamic recipe;
  final bool isSaved;
  final SavedProvider savedProvider;

  const _ModernRecipeCard({
    required this.recipe,
    required this.isSaved,
    required this.savedProvider,
  });

  @override
  State<_ModernRecipeCard> createState() => _ModernRecipeCardState();
}

class _ModernRecipeCardState extends State<_ModernRecipeCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeScreen(),
            settings: RouteSettings(arguments: widget.recipe),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _isPressed
                  ? const Color(0xfffe0000).withOpacity(0.4)
                  : const Color(0xfffe0000).withOpacity(0.08),
              width: _isPressed ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? const Color(0xfffe0000).withOpacity(0.2)
                    : Colors.black.withOpacity(0.06),
                blurRadius: _isPressed ? 28 : 20,
                offset: Offset(0, _isPressed ? 12 : 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with gradient overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 220,
                      child: ReusableNetworkImage(
                        imageUrl: widget.recipe.recipeImage,
                      ),
                    ),
                  ),
                  // Enhanced gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.5),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Bookmark button with enhanced styling
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _BookmarkButton(
                      isSaved: widget.isSaved,
                      onPressed: () {
                        context.read<SavedProvider>().addAndRemoveFromSaved(
                              widget.recipe.recipeId.toString(),
                              widget.recipe.recipeCategory,
                              widget.recipe.cookTime,
                              widget.recipe.prepTime,
                              widget.recipe.recipeImage,
                              widget.recipe.recipeName,
                            );
                      },
                    ),
                  ),
                  // Enhanced time badges at bottom
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: [
                        _buildTimeBadge(
                          icon: UniconsLine.clock,
                          text:
                              '${widget.recipe.prepTime.toStringAsFixed(0)}m prep',
                          color: const Color(0xfffe0000),
                        ),
                        const SizedBox(width: 10),
                        _buildTimeBadge(
                          icon: UniconsLine.fire,
                          text:
                              '${widget.recipe.cookTime.toStringAsFixed(0)}m cook',
                          color: const Color(0xffff6b6b),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Recipe info with enhanced typography
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.recipeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xfffe0000).withOpacity(0.12),
                                const Color(0xffff6b6b).withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xfffe0000).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                UniconsLine.utensils,
                                size: 15,
                                color: Color(0xfffe0000),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                widget.recipe.recipeCategory.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xfffe0000),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xfffe0000).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: const Color(0xfffe0000).withOpacity(0.7),
                          ),
                        ),
                      ],
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

  Widget _buildTimeBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated bookmark button
class _BookmarkButton extends StatefulWidget {
  final bool isSaved;
  final VoidCallback onPressed;

  const _BookmarkButton({
    required this.isSaved,
    required this.onPressed,
  });

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isSaved
                ? const Color(0xfffe0000)
                : Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isSaved
                  ? const Color(0xfffe0000)
                  : const Color(0xfffe0000).withOpacity(0.3),
              width: _isPressed ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSaved
                    ? const Color(0xfffe0000).withOpacity(0.4)
                    : Colors.black.withOpacity(0.15),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: Icon(
            widget.isSaved ? UniconsLine.bookmark : UniconsLine.bookmark,
            color: widget.isSaved ? Colors.white : const Color(0xfffe0000),
            size: 22,
          ),
        ),
      ),
    );
  }
}
