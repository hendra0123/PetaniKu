part of 'pages.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String message = 'Please try to functions below.';
  String? simNumber;
  bool? isChecked = false;

  late UserViewModel userViewModel;

  Future<void> requestPhoneCallPermission() async {
    final status = await Permission.phone.status;

    if (status.isDenied || status.isRestricted) {
      await Permission.phone.request();
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return;
    }
    if (await Permission.phone.isGranted) {
      try {
        String result = await GetPhoneNumber().getPhoneNumber();
        setState(() => simNumber = result);
      } catch (e) {
        setState(() => message = e.toString());
      }
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _validateAndSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await requestPhoneCallPermission();
      final enteredPhoneNumber = _phoneController.text.trim();

      if (simNumber == null && mounted) {
        WidgetUtil.showSnackBar(context, "Nomor telepon SIM tidak tersedia.", Colors.red);
        return;
      }
      if (enteredPhoneNumber != simNumber && simNumber!.isNotEmpty && mounted) {
        WidgetUtil.showSnackBar(context,
            "Nomor tidak sesuai dengan nomor SIM. Harap periksa kembali nomor Anda.", Colors.red);
        return;
      }

      fetchRegister();
    }
  }

  Future<void> fetchRegister() async {
    try {
      String message =
          await userViewModel.postRegister(_nameController.text, _phoneController.text);
      if (mounted) {
        WidgetUtil.showSnackBar(context, message, null);
        Navigator.of(context).pushAndRemoveUntil(
          WidgetUtil.getRoute(const MainNavigationPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) WidgetUtil.showSnackBar(context, e.toString(), Colors.red);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Izin Diperlukan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              "Aplikasi membutuhkan izin untuk mengakses nomor telepon Anda agar dapat berfungsi dengan baik. "),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Kembali"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userViewModel = Provider.of<UserViewModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildFormContent(),
                  ),
                ),
                _buildLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        const Text(
          'Daftar Akun',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF031749),
          ),
        ),
        const SizedBox(height: 16),
        _buildCarousel(),
        const SizedBox(height: 16),
        _buildForm(),
      ],
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      items: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage("assets/images/pdi${3 - index}.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
        );
      }),
      options: CarouselOptions(
        height: 180,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            cursorColor: const Color(0xFF082367),
            controller: _nameController,
            decoration: _inputDecoration('Nama'),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mohon masukkan nama anda';
              } else if (value.length <= 2) {
                return 'Nama harus lebih dari 2 huruf';
              } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                return 'Nama hanya boleh mengandung huruf A-Z';
              } else {
                return null;
              }
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            cursorColor: const Color(0xFF082367),
            controller: _phoneController,
            decoration: _inputDecoration('Nomor Telepon'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value == null || value.isEmpty ? 'Mohon masukkan nomor telepon anda' : null,
          ),
          const SizedBox(height: 32),
          _buildButton(
            text: 'Daftar',
            backgroundColor: const Color(0xFF729762),
            textColor: Colors.white,
            onPressed: _validateAndSubmit,
          ),
          const SizedBox(height: 16),
          const Row(children: <Widget>[
            Expanded(child: Divider()),
            SizedBox(
              width: 16,
            ),
            Text("atau"),
            SizedBox(
              width: 16,
            ),
            Expanded(child: Divider()),
          ]),
          const SizedBox(height: 16),
          _buildButton(
            text: 'Masuk',
            backgroundColor: Colors.white,
            textColor: const Color(0xFF729762),
            borderColor: const Color(0xFF729762),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                WidgetUtil.getRoute(const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderColor != null ? BorderSide(color: borderColor, width: 1.5) : BorderSide.none,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF082367)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF082367), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF031749), width: 1.5),
      ),
      border: const OutlineInputBorder(),
    );
  }

  Widget _buildLoadingOverlay() {
    return Builder(builder: (_) {
      if (userViewModel.status == Status.loading) {
        return Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF729762)),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
