part of 'statement_widgets.dart';

/// شيت الفلترة — نطاق تاريخ + نوع الحركة.
///
/// بترجع [StatementFilter] لو المستخدم طبّق، و`null` لو قفل الشيت.
Future<StatementFilter?> showStatementFilterSheet(
  BuildContext context, {
  required StatementFilter current,
}) {
  return showModalBottomSheet<StatementFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StatementFilterSheet(current: current),
  );
}

class _StatementFilterSheet extends StatefulWidget {
  final StatementFilter current;

  const _StatementFilterSheet({required this.current});

  @override
  State<_StatementFilterSheet> createState() => _StatementFilterSheetState();
}

class _StatementFilterSheetState extends State<_StatementFilterSheet> {
  late DateTime? _fromDate = widget.current.fromDate;
  late DateTime? _toDate = widget.current.toDate;
  late TransactionType? _type = widget.current.transactionType;

  /// أقدم تاريخ نسمح باختياره — الحركات مش بترجع لأبعد من كده عمليًا.
  static final DateTime _firstDate = DateTime(2020);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SafeArea(
        top: false,
        // الشيت بيبقى أطول من الشاشة على الموبايلات الصغيرة، فبيبقى
        // قابل للتمرير بدل ما يعمل overflow.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // مقبض الشيت.
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Gap(16.h),
              Row(
                children: [
                  // `Expanded` عشان العنوان ما يزقّش زر "مسح الكل" بره
                  // الشاشة (كان بيعمل overflow).
                  Expanded(
                    child: Text(
                      'فلترة الحركات',
                      style: TextStyles.boldStyle(
                        18,
                        color: AppColors.brandBlueDeep,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_hasAnySelection)
                    TextButton(
                      onPressed: () => setState(() {
                        _fromDate = null;
                        _toDate = null;
                        _type = null;
                      }),
                      child: Text(
                        'مسح الكل',
                        style: TextStyles.boldStyle(
                          13,
                          color: AppColors.error,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              Gap(8.h),
              // ─── نوع الحركة ─────────────────────────────
              Text(
                'نوع الحركة',
                style: TextStyles.boldStyle(
                  14,
                  color: AppColors.textPrimary,
                  weight: FontWeight.w700,
                ),
              ),
              Gap(10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  // "الكل" = مفيش فلتر نوع.
                  _TypeChip(
                    label: 'الكل',
                    isSelected: _type == null,
                    onTap: () => setState(() => _type = null),
                  ),
                  // بنعرض الاسم العربي، وبنبعت الـ apiValue للباك اند.
                  for (final type in TransactionType.filterable)
                    _TypeChip(
                      label: type.label,
                      isSelected: _type == type,
                      onTap: () => setState(() => _type = type),
                    ),
                ],
              ),
              Gap(20.h),
              // ─── نطاق التاريخ ───────────────────────────
              Text(
                'الفترة',
                style: TextStyles.boldStyle(
                  14,
                  color: AppColors.textPrimary,
                  weight: FontWeight.w700,
                ),
              ),
              Gap(10.h),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'من',
                      value: _fromDate,
                      onTap: _pickFromDate,
                      onClear: _fromDate == null
                          ? null
                          : () => setState(() => _fromDate = null),
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: _DateField(
                      label: 'إلى',
                      value: _toDate,
                      onTap: _pickToDate,
                      onClear: _toDate == null
                          ? null
                          : () => setState(() => _toDate = null),
                    ),
                  ),
                ],
              ),
              Gap(24.h),
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(
                    StatementFilter(
                      fromDate: _fromDate,
                      toDate: _toDate,
                      transactionType: _type,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.mainAppColor,
                    foregroundColor: AppColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text('تطبيق الفلتر', style: TextStyles.whiteText(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasAnySelection =>
      _fromDate != null || _toDate != null || _type != null;

  Future<void> _pickFromDate() async {
    final picked = await _pickDate(
      initial: _fromDate ?? _toDate ?? DateTime.now(),
      // "من" ما يزيدش عن "إلى".
      lastDate: _toDate ?? DateTime.now(),
    );
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final picked = await _pickDate(
      initial: _toDate ?? DateTime.now(),
      // "إلى" ما يقلّش عن "من".
      firstDate: _fromDate ?? _firstDate,
    );
    if (picked != null) setState(() => _toDate = picked);
  }

  Future<DateTime?> _pickDate({
    required DateTime initial,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final first = firstDate ?? _firstDate;
    final last = lastDate ?? DateTime.now();
    // لو الحدود اتعاكست (تاريخ مختار بره النطاق) بنوسّع النطاق بدل ما
    // الـ picker يعمل assert ويقع.
    final safeInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);

    return showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: first,
      lastDate: last.isBefore(first) ? first : last,
      locale: const Locale('ar'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.mainAppColor,
            onPrimary: AppColors.whiteColor,
            surface: AppColors.bgSecondary,
            onSurface: AppColors.textPrimary,
          ),
          // الـ textTheme بتاع التطبيق فيه مقاسات كبيرة (`bodyLarge` 30.sp
          // و `headlineLarge` 35.sp) والـ date picker بياخد ستايلاته منها،
          // فبيطلع ضخم. بنحدد مقاسات ماتيريال الطبيعية للـ picker بس
          // من غير ما نلمس ثيم التطبيق.
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.bgSecondary,
            surfaceTintColor: Colors.transparent,
            // "اختيار التاريخ"
            headerHelpStyle: _pickerStyle(12, FontWeight.w500),
            // "الأربعاء، ٢ سبتمبر"
            headerHeadlineStyle: _pickerStyle(24, FontWeight.w600),
            // "سبتمبر ٢٠٢٦"
            rangePickerHeaderHelpStyle: _pickerStyle(12, FontWeight.w500),
            rangePickerHeaderHeadlineStyle: _pickerStyle(24, FontWeight.w600),
            // أرقام الأيام وحروف أيام الأسبوع.
            dayStyle: _pickerStyle(14, FontWeight.w500),
            weekdayStyle: _pickerStyle(13, FontWeight.w600),
            yearStyle: _pickerStyle(14, FontWeight.w500),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mainAppColor,
              textStyle: _pickerStyle(14, FontWeight.w700),
            ),
          ),
        ),
        child: child!,
      ),
    );
  }

  /// ستايل نصوص الـ date picker — مقاسات ثابتة مش `.sp` عشان ما تتضخمش
  /// تاني مع `ScreenUtil`.
  static TextStyle _pickerStyle(double size, FontWeight weight) {
    return TextStyle(fontSize: size, fontWeight: weight, height: 1.2);
  }
}

/// شيب اختيار نوع الحركة.
class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainAppColor : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.mainAppColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyles.boldStyle(
            13,
            color: isSelected ? AppColors.whiteColor : AppColors.textSecondary,
            weight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// حقل اختيار تاريخ — بيعرض التاريخ المختار أو "اختر".
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16.sp,
              color: AppColors.textHint,
            ),
            Gap(8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyles.lightStyle(11, color: AppColors.textHint),
                  ),
                  Gap(2.h),
                  Text(
                    value == null ? 'اختر' : StatementFormat.date(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.boldStyle(
                      12,
                      color: value == null
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              InkWell(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 16.sp,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
