import 'package:e_comm/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from("profiles")
          .select()
          .eq("id", user.id)
          .maybeSingle()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => null, // ✅ return null so fallback is used
          );

      // if no profile row exists, create one
      if (response == null) {
        await Supabase.instance.client.from("profiles").insert({
          "id": user.id,
          "name": user.userMetadata?['name'] ?? "User",
          "email": user.email,
        });
      }

      setState(() {
        userProfile = {
          "name": response?['name'] ?? user.userMetadata?['name'] ?? "User",
          "email": response?['email'] ?? user.email ?? "",
          "address": response?['address'] ?? "",
          "city": response?['city'] ?? "",
          "state": response?['state'] ?? "",
          "postal_code": response?['postal_code'] ?? "",
          "country": response?['country'] ?? "",
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userProfile = {
          "name": user.userMetadata?['name'] ?? "Guest",
          "email": user.email ?? "",
        };
        isLoading = false;
      });
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProfile == null || userProfile!.isEmpty) {
      return const Scaffold(body: Center(child: Text("No profile found")));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _buildAvatar(),
              const SizedBox(height: 16),
              Text(
                userProfile!['name'] ?? "User",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                userProfile!['email'] ?? "userEmail",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Divider(),

              _buildSectionHeader('Shipping Address'),
              _buildInfoTile(
                Icons.home_outlined,
                'Address',
                userProfile!['address'] ?? 'Not provided',
              ),
              _buildInfoTile(
                Icons.location_city_outlined,
                'City',
                userProfile!['city'] ?? 'Not provided',
              ),
              _buildInfoTile(
                Icons.map_outlined,
                'State / Postal Code',
                "${userProfile!['state'] ?? ''} ${userProfile!['postal_code'] ?? ''}",
              ),
              _buildInfoTile(
                Icons.public_outlined,
                'Country',
                userProfile!['country'] ?? 'Not provided',
              ),

              const SizedBox(height: 16),
              const Divider(),

              _buildSectionHeader('Payment Methods'),
              const ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('Payment Method'),
                subtitle: Text("Not Provided"),
              ),
              const SizedBox(height: 20),

              // ✅ Logout Button
              GestureDetector(
                onTap: () {
                  _logout();
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Logout",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade200,
      child: const Icon(Icons.person, size: 60),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    if (subtitle.trim().isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
