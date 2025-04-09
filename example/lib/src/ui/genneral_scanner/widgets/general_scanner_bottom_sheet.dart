import 'package:flutter/cupertino.dart';

class GeneralScannerBottomSheet extends StatelessWidget {
  const GeneralScannerBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      color: CupertinoTheme.of(context).barBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _GroupButton(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Switch(
                title: "Continuous\n Scanning",
                onChanged: (bool value) {},
              ),
              _Switch(
                title: "Multi-Barcode\n Scanning",
                onChanged: (bool value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupButton extends StatefulWidget {
  const _GroupButton();

  @override
  State<_GroupButton> createState() => _GroupButtonState();
}

class _GroupButtonState extends State<_GroupButton> {
  late final theme = CupertinoTheme.of(context);

  final groupButtonName = ["Full Image", "Square", "Rectangular"];
  late String selectedGroupName = groupButtonName.first;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...groupButtonName.map(
          (name) => buildButton(
            text: name,
            isSelected: selectedGroupName == name,
            onPressed: () => setState(() {
              selectedGroupName = name;
            }),
          ),
        ),
      ],
    );
  }

  Widget buildButton({
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      pressedOpacity: 0.9,
      child: Row(
        children: [
          Icon(
            CupertinoIcons.circle_fill,
            size: 8,
            color: isSelected
                ? theme.primaryContrastingColor
                : CupertinoColors.transparent,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: theme.primaryContrastingColor.withAlpha(
                ((isSelected ? 1 : 0.6) * 255.0).round(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.title, required this.onChanged});

  final String title;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    bool currentValue = false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        const SizedBox(width: 8),
        StatefulBuilder(builder: (context, setState) {
          return CupertinoSwitch(
            value: currentValue,
            activeColor: CupertinoColors.activeBlue,
            onChanged: (bool? value) {
              onChanged(value ?? false);
              setState(() => currentValue = value ?? false);
            },
          );
        }),
      ],
    );
  }
}
