import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/frog_avatar.dart';
import '../../shared/header.dart';
import '../../shared/v2.dart';
import '../../state/app_context.dart';

const String kDefaultName = 'Meera Sharma';
const String kUserId = '48213907';
const List<String> kGenders = <String>[
  'Woman',
  'Man',
  'Non-binary',
  'Prefer not to say',
];
const int kMaxPhotos = 6;
final RegExp kNameOk = RegExp(r'^[A-Za-z0-9 ]{2,24}$');

const String _checkSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>';
const String _warnSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.25" stroke-linecap="round"><circle cx="12" cy="12" r="9.5"/><path d="M12 7.5v5.5M12 16.5v.01"/></svg>';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.initialPhotos = 0,
    this.initialVerified = false,
    this.initialSheet,
    this.onAddPhoto,
    this.onRemovePhoto,
  });

  final int initialPhotos; // test-only
  final bool initialVerified; // test-only
  final String? initialSheet; // test-only: 'name' | 'gender' | 'interests'
  final VoidCallback? onAddPhoto;
  final VoidCallback? onRemovePhoto;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String _name;
  String _gender = 'Woman';
  late int _photos = widget.initialPhotos;
  DateTime? _birthday;
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _pickedPhotos = <Uint8List>[];

  /// Local demo logic: verified = at least one photo. TODO: real
  /// verification must come from the backend later.
  bool get _isVerified => _photos > 0;

  @override
  void initState() {
    super.initState();
    final AppContextState app = context.read<AppContextState>();
    _name = app.profileName.trim().length >= 2 ? app.profileName : kDefaultName;
    if (widget.initialSheet != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSheet(widget.initialSheet!);
      });
    }
  }

  @override
  void dispose() {
    AppSnack.hide();
    super.dispose();
  }

  void _snack(String message) {
    AppSnack.show(
      context,
      message,
      bottom: 24 + MediaQuery.paddingOf(context).bottom,
    );
  }

  void _openSheet(String sheet) {
    switch (sheet) {
      case 'name':
        showAppSheet<void>(
          context,
          builder: (sheetContext) => _NameSheet(
            saved: _name,
            onSave: (String value) {
              Navigator.of(sheetContext).pop();
              setState(() => _name = value);
              context.read<AppContextState>().saveProfile(value);
              _snack('Saved');
            },
          ),
        );
      case 'gender':
        showAppSheet<void>(
          context,
          builder: (sheetContext) => _GenderSheet(
            selected: _gender,
            onSelect: (String value) {
              Navigator.of(sheetContext).pop();
              setState(() => _gender = value);
              _snack('Saved');
            },
          ),
        );
    }
  }

  /// Reusable bottom sheet: gallery / camera. Used by both the avatar edit
  /// button and the Add photo tile.
  Future<void> _pickPhotoSheet() {
    return showAppSheet<void>(
      context,
      action: true,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _pickRow(
            label: 'Choose from gallery',
            onTap: () => _pickImage(sheetContext, ImageSource.gallery),
          ),
          _pickRow(
            label: 'Take a photo',
            onTap: () => _pickImage(sheetContext, ImageSource.camera),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: AppTap(
              onTap: () => Navigator.of(sheetContext).pop(),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.ink2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickRow({required String label, required VoidCallback onTap}) {
    return SizedBox(
      height: 56,
      child: AppTap(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext sheetContext, ImageSource source) async {
    final XFile? picked;
    try {
      picked = await _picker.pickImage(source: source, maxWidth: 1200);
    } catch (_) {
      // Permission denied or picker failure.
      if (mounted) _snack('Could not access photos');
      return;
    }
    if (!mounted || !sheetContext.mounted) return;
    if (picked == null) return; // cancelled
    final Uint8List bytes = await picked.readAsBytes();
    if (!mounted || !sheetContext.mounted) return;
    Navigator.of(sheetContext).pop();
    if (_photos >= kMaxPhotos) return;
    setState(() {
      _photos++;
      _pickedPhotos.add(bytes);
    });
    widget.onAddPhoto?.call();
    _snack('Saved');
  }

  void _addPhoto() => _pickPhotoSheet();

  void _removePhoto(int index) {
    setState(() {
      _photos--;
      if (index < _pickedPhotos.length) _pickedPhotos.removeAt(index);
    });
    widget.onRemovePhoto?.call();
    _snack('Saved');
  }

  Future<void> _pickBirthday() async {
    final DateTime now = DateTime.now();
    final DateTime today18 = DateTime(now.year - 18, now.month, now.day);
    final DateTime initial = _birthday ?? today18;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: today18,
    );
    if (picked == null) return; // cancelled
    setState(() => _birthday = picked);
  }

  Future<void> _copyId() async {
    await Clipboard.setData(const ClipboardData(text: kUserId));
    _snack('User ID copied');
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return FadeIn(
      child: Material(
        color: AppColors.screen,
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Header(title: 'Edit profile', onBack: navigation.back),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _avatarBlock(),
                      const SizedBox(height: 24),
                      _photosSection(),
                      const SizedBox(height: 24),
                      _verifiedCard(),
                      const SizedBox(height: 24),
                      _rows(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarBlock() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            const FrogAvatar(size: 96, ring: 3),
            Positioned(
              right: -14,
              bottom: -14,
              child: AppTap(
                label: 'Change avatar',
                onTap: _pickPhotoSheet,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                    child: const Center(
                      child: AppIcon(
                        name: 'edit',
                        size: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Tap to change',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.sub,
          ),
        ),
      ],
    );
  }

  Widget _photosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Photos',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            height: 26 / 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add up to 6. Clear, recent photos build trust.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.sub,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 144,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 4),
            children: <Widget>[
              for (int i = 0; i < _photos; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _PhotoTile(
                    index: i,
                    bytes: i < _pickedPhotos.length ? _pickedPhotos[i] : null,
                    onRemove: () => _removePhoto(i),
                  ),
                ),
              if (_photos < kMaxPhotos) _AddPhotoTile(onTap: _addPhoto),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verifiedCard() {
    final bool verified = _isVerified;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _EditProfileScreenState.cardDecoration(),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.onlineCyan,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppIcon(name: 'shield', size: 22, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Get verified',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  'Verified profiles earn more trust',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.sub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: verified ? AppColors.onlineCyan : AppColors.card,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (verified)
                  SvgPicture.string(
                    _checkSvg,
                    width: 12,
                    height: 12,
                    colorFilter: const ColorFilter.mode(
                      AppColors.ink,
                      BlendMode.srcIn,
                    ),
                    excludeFromSemantics: true,
                  ),
                const SizedBox(width: 4),
                Text(
                  verified ? 'Verified' : 'Not verified',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const AppIcon(name: 'chev', size: 18, color: AppColors.ink2),
        ],
      ),
    );
  }

  Widget _rows() {
    return Column(
      children: <Widget>[
        _Row(label: 'Name', value: _name, onTap: () => _openSheet('name')),
        Column(
          children: <Widget>[
            _Row(
              label: 'Birthday',
              value: _birthday == null
                  ? '12 Mar 2004'
                  : DateFormat('d MMM yyyy').format(_birthday!),
              onTap: _pickBirthday,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Used to confirm you're 18 or older.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.sub,
                  ),
                ),
              ),
            ),
          ],
        ),
        _Row(
          label: 'User ID',
          value: kUserId,
          trail: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppTap(
              label: 'Copy user ID',
              onTap: _copyId,
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: AppIcon(
                    name: 'copy',
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
        _Row(
          label: 'Gender',
          value: _gender,
          onTap: () => _openSheet('gender'),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration() => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(28)),
    border: Border.all(color: AppColors.divider),
    boxShadow: const <BoxShadow>[
      BoxShadow(color: Color(0x148B5CF6), offset: Offset(0, 4), blurRadius: 14),
    ],
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.onTap,
    this.trail,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trail;

  @override
  Widget build(BuildContext context) {
    final Widget body = Row(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    color: AppColors.sub,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              trail ??
                  const AppIcon(name: 'chev', size: 18, color: AppColors.ink2),
            ],
          ),
        ),
      ],
    );
    return SizedBox(
      height: 64,
      child: onTap != null
          ? AppTap(onTap: onTap, child: _wrapped(body))
          : _wrapped(body),
    );
  }

  Widget _wrapped(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _EditProfileScreenState.cardDecoration(),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Photo tiles
// ---------------------------------------------------------------------------
const List<Color> _tileTints = <Color>[
  AppColors.tintVip,
  AppColors.tintInvite,
  AppColors.tintTokens,
];

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.index, this.bytes, required this.onRemove});

  final int index;
  final Uint8List? bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 140,
      decoration: BoxDecoration(
        color: _tileTints[index % 3],
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          if (bytes != null)
            Positioned.fill(
              child: Image.memory(
                bytes!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            )
          else
            Positioned.fill(child: CustomPaint(painter: _PhotoArtPainter())),
          Positioned(
            top: 0,
            right: 0,
            child: AppTap(
              label: 'Remove photo ${index + 1}',
              onTap: onRemove,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: 3.141592653589793 / 4,
                      child: const AppIcon(
                        name: 'plus',
                        size: 14,
                        color: AppColors.ink,
                        stroke: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint primary = Paint()
      ..color = AppColors.primary.withValues(alpha: .4);
    final Paint coin = Paint()..color = AppColors.coin;
    canvas.drawCircle(const Offset(52, 56), 20, primary);
    final Path shoulders = Path()
      ..moveTo(14, 140)
      ..lineTo(14, 140)
      ..cubicTo(14, 110, 31, 96, 52, 96)
      ..cubicTo(73, 96, 90, 110, 90, 140)
      ..close();
    canvas.drawPath(shoulders, primary);
    canvas.drawCircle(const Offset(86, 24), 8, coin);
  }

  @override
  bool shouldRepaint(_PhotoArtPainter oldDelegate) => false;
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      label: 'Add photo',
      onTap: onTap,
      child: Container(
        width: 104,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomPaint(
          painter: DashedRRectPainter(),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppIcon(name: 'plus', size: 28, color: AppColors.primary),
              SizedBox(height: 4),
              Text(
                'Add photo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets
// ---------------------------------------------------------------------------
class _NameSheet extends StatefulWidget {
  const _NameSheet({required this.saved, required this.onSave});

  final String saved;
  final ValueChanged<String> onSave;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.saved,
  );
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  String get _trimmed => _controller.text.trim();
  bool get _valid => kNameOk.hasMatch(_trimmed);
  bool get _changed => _trimmed != widget.saved;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool invalid = _trimmed.isNotEmpty && !_valid;
    final Color border = invalid
        ? AppColors.ink
        : _focused
        ? AppColors.primary
        : AppColors.divider;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Name',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Display name',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 2),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              maxLength: 30,
              onChanged: (_) => setState(() {}),
              onTap: () => setState(() => _focused = true),
              onTapOutside: (_) => setState(() => _focused = false),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 20,
            child: _trimmed.isEmpty
                ? null
                : Row(
                    children: <Widget>[
                      SvgPicture.string(
                        _valid ? _checkSvg : _warnSvg,
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          _valid ? AppColors.ink : AppColors.badge,
                          BlendMode.srcIn,
                        ),
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _valid ? 'Looks good' : 'Use 2 to 24 characters, letters and numbers only',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 16 / 12,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _changed && _valid ? 'Ready to save' : 'Change your name to save',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.sub,
              ),
            ),
          ),
          const SizedBox(height: 8),
          NeoButton(
            'Save changes',
            onPressed: _changed && _valid
                ? () => widget.onSave(_trimmed)
                : null,
          ),
        ],
      ),
    );
  }
}

class _GenderSheet extends StatelessWidget {
  const _GenderSheet({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Gender',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            height: 28 / 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        for (final String gender in kGenders)
          InkWell(
            onTap: () => onSelect(gender),
            child: Container(
              height: 56,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    gender,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 24 / 16,
                      color: AppColors.ink,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gender == selected
                            ? AppColors.primary
                            : AppColors.lvGray,
                        width: 2,
                      ),
                    ),
                    child: gender == selected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
