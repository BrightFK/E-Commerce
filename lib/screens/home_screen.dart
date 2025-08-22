import 'package:e_comm/extension.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "Shoes", "Clothes", "Bags", "Accessories"];
    final List<Product> products = dummyProducts;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "E-Commmerce App",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      // ✅ PageView for navigation
      body: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            selected = index;
          });
        },
        children: [
          // -------- Home Page --------
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// Category List
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return Chip(
                        backgroundColor: index == 0
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        label: Text(
                          categories[index],
                          style: GoogleFonts.poppins(
                            color: index == 0
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                /// Products Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.6,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, product);
                  },
                ),
              ],
            ),
          ),

          const CartScreen(),
          ProfileScreen(),
        ],
      ),

      // ✅ Stylish Bottom Bar
      bottomNavigationBar: StylishBottomBar(
        option: BubbleBarOptions(
          barStyle: BubbleBarStyle.horizontal,
          // barStyle: BubbleBarStyle.vertical,
          bubbleFillStyle: BubbleFillStyle.fill,
          inkColor: Colors.teal.shade900,
          inkEffect: true,
          // bubbleFillStyle: BubbleFillStyle.outlined,
          opacity: 0.3,
        ),
        items: [
          BottomBarItem(
            icon: const Icon(Icons.home_outlined),
            title: const Text('Home'),
          ),
          BottomBarItem(
            icon: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Cart'),
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline),
            title: const Text('Profile'),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 8,
        currentIndex: selected,
        onTap: (index) {
          setState(() {
            selected = index;
          });
          controller.jumpToPage(index);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                product.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${product.price}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
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
}
