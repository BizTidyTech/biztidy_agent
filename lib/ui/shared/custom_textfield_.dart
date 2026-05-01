// ignore_for_file: must_be_immutable

import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:flutter/material.dart';

TextStyle labelTextStyles = TextStyle(
  fontSize: 15,
  color: Colors.grey[500],
);

const TextStyle hintTextStyles = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w300,
  color: Color.fromRGBO(153, 153, 153, 1),
);

// Cached borders — OutlineInputBorder + BorderRadius + BorderSide allocated
// once, not on every CustomTextfield.build() call.
final _enabledBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AppColors.kPrimaryColor, width: 2.0),
  borderRadius: BorderRadius.circular(15.0),
);
final _focusedBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AppColors.primaryThemeColor, width: 2.0),
  borderRadius: BorderRadius.circular(15.0),
);

class CustomTextfield extends StatefulWidget {
  const CustomTextfield({
    super.key,
    this.fillColor,
    this.labelText,
    this.hintText,
    this.hintStyle,
    this.textEditingController,
    this.hasSuffixIcon = false,
    this.onSuffixIconPressed,
    this.suffixIcon,
    this.focusNode,
    this.initialValue,
    this.hasPrefixIcon = false,
    this.onPrefixIconPressed,
    this.keyboardType,
    this.prefixText,
    this.readOnly,
    this.prefixStyle,
    this.floatingLabelStyle,
    this.suffixIconSize,
    this.letterSpacing,
    this.obscureText,
    this.onChanged,
    this.maxLines,
    this.minLines,
    this.onTap,
    this.inputStringStyle,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization,
    this.contentpadding,
    this.scrollPadding,
    this.onSubmitted,
    this.autofocus,
    this.enabled = true,
    this.suffixText,
    this.textMaxLength,
  });

  final EdgeInsets? scrollPadding;
  final Color? fillColor;
  final String? labelText;
  final String? prefixText;
  final String? initialValue;
  final double? suffixIconSize;
  final double? letterSpacing;
  final String? suffixText;
  final String? hintText;
  final TextStyle? hintStyle;
  final bool? enabled;
  final bool? readOnly;
  final bool? autofocus;
  final int? maxLines;
  final int? minLines;
  final int? textMaxLength;
  final bool hasSuffixIcon;
  final bool hasPrefixIcon;
  final bool? obscureText;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextStyle? inputStringStyle;
  final TextStyle? prefixStyle;
  final TextStyle? floatingLabelStyle;
  final TextInputType? keyboardType;
  final TextEditingController? textEditingController;
  final TextInputAction textInputAction;
  final TextCapitalization? textCapitalization;
  final void Function()? onSuffixIconPressed;
  final void Function()? onPrefixIconPressed;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final EdgeInsetsGeometry? contentpadding;

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextFormField(
        style: widget.inputStringStyle ??
            AppStyles.inputStringStyle(AppColors.fullBlack),
        controller: widget.textEditingController,
        maxLength: widget.textMaxLength,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText ?? false,
        minLines: widget.minLines,
        maxLines: widget.obscureText == true ? 1 : widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          fillColor: widget.fillColor ?? AppColors.plainWhite,
          filled: true,
          enabled: widget.enabled ?? true,
          suffixIcon: widget.suffixIcon,
          contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          enabledBorder: _enabledBorder,
          focusedBorder: _focusedBorder,
          labelStyle: labelTextStyles,
          hintStyle: widget.hintStyle ?? hintTextStyles,
          counterText: '',
        ),
      ),
    );
  }
}
