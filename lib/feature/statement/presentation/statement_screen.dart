import 'package:eman_shareholders/core/bloc/paginated_bloc/exports.dart';
import 'package:eman_shareholders/core/cache_manager/cache_manager.dart';
import 'package:eman_shareholders/core/extensions/extensions.dart';
import 'package:eman_shareholders/core/router/app_router.dart';
import 'package:eman_shareholders/core/service_locator/service_locator.dart';
import 'package:eman_shareholders/core/session/session_manager.dart';
import 'package:eman_shareholders/core/theme/app_colors.dart';
import 'package:eman_shareholders/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../data/models/statement_model.dart';
import 'view_model/statement_cubit.dart';
import 'widgets/statement_widgets.dart';

class StatementScreen extends StatelessWidget {
  const StatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatementCubit>(
      create: (_) => getIt<StatementCubit>()..getStatement(),
      child: const _StatementView(),
    );
  }
}

class _StatementView extends StatelessWidget {
  const _StatementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: BlocBuilder<StatementCubit, BaseState<StatementModel>>(
          builder: (context, state) {
            final cubit = context.read<StatementCubit>();

            // أول تحميل — مفيش بيانات معروضة لسه.
            if ((state.isLoading || state.isInitial) && !state.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isFailure && !state.hasData) {
              return _StatementError(
                message: state.errorMessage ?? 'حصلت مشكلة في تحميل البيانات',
                onRetry: cubit.getStatement,
              );
            }

            final statement = state.data;
            if (statement == null) return const SizedBox.shrink();

            return RefreshIndicator.adaptive(
              color: AppColors.mainAppColor,
              backgroundColor: AppColors.bgSecondary,
              // مسافة أصغر بتخلي السحب يحس أخف من الافتراضي.
              displacement: 28.h,
              edgeOffset: 0,
              strokeWidth: 2.4,
              onRefresh: cubit.refreshStatement,
              child: CustomScrollView(
                // `BouncingScrollPhysics` بيمنع الستريتش المطاطي القوي
                // اللي كان بيحصل مع `AlwaysScrollableScrollPhysics`، وفي
                // نفس الوقت بيسمح بالسحب للتحديث لو المحتوى قصير.
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList.list(
                      children: [
                        Gap(8.h),
                        StatementGreeting(name: statement.shareholder.name),
                        Gap(16.h),
                        StatementHeaderCard(
                          contributedAmount:
                              statement.shareholder.contributedAmount,
                          companyPercentage:
                              statement.shareholder.companyPercentage,
                          accruedProfit: statement.accruedProfit,
                        ),
                        Gap(16.h),
                        CapitalSummaryCard(statement: statement),
                        Gap(16.h),
                        AccountInfoCard(shareholder: statement.shareholder),
                        Gap(20.h),
                        // ─── الحركات: فلتر ← ليست ← صفحات ─────
                        StatementFilterBar(
                          filter: cubit.filter,
                          onOpenFilter: () => _openFilter(context, cubit),
                          onFilterChanged: cubit.applyFilter,
                        ),
                        Gap(12.h),
                        StatementEntriesCard(
                          entries: statement.entries,
                          isLoading: state.isLoadingMore,
                          isFiltered: cubit.filter.isActive,
                          onClearFilter: cubit.clearFilter,
                        ),
                        Gap(16.h),
                        StatementPaginationBar(
                          pageIndex: statement.entries.pageIndex,
                          totalPages: statement.entries.totalPages,
                          count: statement.entries.count,
                          isLoading: state.isLoadingMore,
                          onPageSelected: cubit.goToPage,
                        ),
                        Gap(20.h),
                        const _LogoutButton(),
                        Gap(24.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openFilter(BuildContext context, StatementCubit cubit) async {
    final result = await showStatementFilterSheet(
      context,
      current: cubit.filter,
    );
    if (result != null) await cubit.applyFilter(result);
  }
}

/// حالة الخطأ — رسالة وزر إعادة المحاولة.
class _StatementError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StatementError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 54.sp,
              color: AppColors.error,
            ),
            Gap(14.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyles.lightStyle(15, color: AppColors.textSecondary),
            ),
            Gap(20.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.mainAppColor,
                foregroundColor: AppColors.whiteColor,
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text('إعادة المحاولة', style: TextStyles.whiteText(15)),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر تسجيل الخروج تحت الصفحة.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _confirmLogout(context),
      child: Text(
        'تسجيل الخروج',
        style: TextStyles.boldStyle(
          15,
          color: AppColors.error,
          weight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Text(
          'تسجيل الخروج',
          style: TextStyles.boldStyle(17, color: AppColors.textPrimary),
        ),
        content: Text(
          'متأكد إنك عايز تسجّل الخروج؟',
          style: TextStyles.lightStyle(14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'إلغاء',
              style: TextStyles.lightStyle(14, color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'خروج',
              style: TextStyles.boldStyle(14, color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    // نمسح الجلسة (Hive + SharedPreferences) عشان السبلاش ما يفتحش
    // كشف الحساب تاني بعد الخروج.
    await getIt<SessionManager>().clear();
    await CacheManager.clear();
    if (!context.mounted) return;
    context.go(AppRouter.login);
  }
}
