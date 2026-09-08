import 'dart:convert';

import 'package:eman_shareholders/feature/statement/data/models/statement_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// نفس الريسبونس اللي الـ API بيرجعه — بنتأكد إن الـ parsing بيقراه صح.
const String _response = '''
{
  "statusCode": 200,
  "message": null,
  "data": {
    "shareholder": {
      "id": 5,
      "name": "أحمد محمود",
      "phoneNumber": "01012345678",
      "address": "القاهرة - مدينة نصر",
      "contributedAmount": 500000.00,
      "ownedPercentage": 25.00,
      "companyPercentage": 20.00,
      "totalProfitReceived": 45000.00,
      "accruedProfit": 3200.50,
      "capitalTreasuryId": 1,
      "capitalTreasuryName": "الخزينة الرئيسية",
      "notes": "مساهم مؤسس",
      "createdAt": "2025-01-10T09:00:00"
    },
    "totalCapitalDeposited": 500000.00,
    "totalCapitalWithdrawn": 50000.00,
    "totalProfitCapitalized": 20000.00,
    "totalProfitDistributed": 45000.00,
    "accruedProfit": 3200.50,
    "entries": {
      "pageIndex": 1,
      "pageSize": 10,
      "count": 42,
      "totalPages": 5,
      "data": [
        {
          "id": 301,
          "voucherNumber": "",
          "date": "2026-08-30T00:00:00",
          "transactionType": "ProfitDistribution",
          "amount": 15000.00,
          "companyShare": 3000.00,
          "shareholderShare": 12000.00,
          "capitalBalanceAfter": 0,
          "treasuryName": "خزينة الأرباح",
          "notes": "تسوية أرباح شهر أغسطس"
        },
        {
          "id": 128,
          "voucherNumber": "PC-2026-0012",
          "date": "2026-08-15T00:00:00",
          "transactionType": "ProfitCapitalization",
          "amount": 20000.00,
          "companyShare": null,
          "shareholderShare": null,
          "capitalBalanceAfter": 520000.00,
          "treasuryName": "الخزينة الرئيسية",
          "notes": "رسملة أرباح على رأس المال"
        },
        {
          "id": 119,
          "voucherNumber": "PAY-2026-0044",
          "date": "2026-07-01T00:00:00",
          "transactionType": "CapitalWithdrawal",
          "amount": 50000.00,
          "companyShare": null,
          "shareholderShare": null,
          "capitalBalanceAfter": 500000.00,
          "treasuryName": "الخزينة الرئيسية",
          "notes": "سحب جزء من رأس المال"
        },
        {
          "id": 3,
          "voucherNumber": "REC-2025-0001",
          "date": "2025-01-10T00:00:00",
          "transactionType": "CapitalDeposit",
          "amount": 500000.00,
          "companyShare": null,
          "shareholderShare": null,
          "capitalBalanceAfter": 500000.00,
          "treasuryName": "الخزينة الرئيسية",
          "notes": "إيداع رأس المال الأولي"
        }
      ]
    }
  }
}
''';

void main() {
  final Map<String, dynamic> data =
      (jsonDecode(_response) as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
  final statement = StatementModel.fromJson(data);

  test('بيانات المساهم بتتقرأ صح', () {
    expect(statement.shareholder.id, 5);
    expect(statement.shareholder.name, 'أحمد محمود');
    expect(statement.shareholder.phoneNumber, '01012345678');
    expect(statement.shareholder.address, 'القاهرة - مدينة نصر');
    expect(statement.shareholder.contributedAmount, 500000.0);
    expect(statement.shareholder.ownedPercentage, 25.0);
    expect(statement.shareholder.companyPercentage, 20.0);
    expect(statement.shareholder.capitalTreasuryName, 'الخزينة الرئيسية');
    expect(statement.shareholder.notes, 'مساهم مؤسس');
    expect(statement.shareholder.createdAt, DateTime(2025, 1, 10, 9));
  });

  test('الإجماليات بتتقرأ صح', () {
    expect(statement.totalCapitalDeposited, 500000.0);
    expect(statement.totalCapitalWithdrawn, 50000.0);
    expect(statement.totalProfitCapitalized, 20000.0);
    expect(statement.totalProfitDistributed, 45000.0);
    expect(statement.accruedProfit, 3200.50);
  });

  test('معلومات الصفحات بتتقرأ صح', () {
    expect(statement.entries.pageIndex, 1);
    expect(statement.entries.pageSize, 10);
    expect(statement.entries.count, 42);
    expect(statement.entries.totalPages, 5);
    expect(statement.entries.data.length, 4);
    expect(statement.entries.hasMore, isTrue);
  });

  test('أنواع الحركات بتتحول صح', () {
    expect(
      statement.entries.data.map((e) => e.transactionType).toList(),
      [
        TransactionType.profitDistribution,
        TransactionType.profitCapitalization,
        TransactionType.capitalWithdrawal,
        TransactionType.capitalDeposit,
      ],
    );
  });

  test('التوزيع بيعرض نصيب المساهم مش المبلغ الكلي', () {
    final distribution = statement.entries.data.first;
    expect(distribution.amount, 15000.0);
    expect(distribution.companyShare, 3000.0);
    expect(distribution.shareholderShare, 12000.0);
    // المعروض للمساهم = نصيبه هو.
    expect(distribution.displayAmount, 12000.0);
  });

  test('الحقول اللي بترجع null ما بتتحولش لصفر بالغلط', () {
    final capitalization = statement.entries.data[1];
    expect(capitalization.companyShare, isNull);
    expect(capitalization.shareholderShare, isNull);
    // لما مفيش نصيب مساهم بنعرض المبلغ نفسه.
    expect(capitalization.displayAmount, 20000.0);
    expect(capitalization.voucherNumber, 'PC-2026-0012');
  });

  test('السحب بيتحدد كحركة خارجة والإيداع كحركة داخلة', () {
    final withdrawal = statement.entries.data[2];
    expect(withdrawal.transactionType.isDebit, isTrue);
    expect(withdrawal.transactionType.isCredit, isFalse);

    final deposit = statement.entries.data[3];
    expect(deposit.transactionType.isCredit, isTrue);
  });

  test('رقم السند الفاضي بيفضل فاضي مش null', () {
    expect(statement.entries.data.first.voucherNumber, isEmpty);
  });

  test('نوع حركة غير معروف ما بيوقعش الـ parsing', () {
    final entry = StatementEntryModel.fromJson({
      'id': 1,
      'transactionType': 'SomethingNew',
      'amount': 10,
    });
    expect(entry.transactionType, TransactionType.unknown);
  });

  test('ريسبونس ناقص أو فاضي ما بيوقعش الـ parsing', () {
    final empty = StatementModel.fromJson({});
    expect(empty.shareholder.name, isEmpty);
    expect(empty.accruedProfit, 0);
    expect(empty.entries.data, isEmpty);
    expect(empty.entries.hasMore, isFalse);
  });

  test('دمج صفحة حركات جديدة بيضيف على الموجود', () {
    final nextPage = PaginatedEntriesModel.fromJson({
      'pageIndex': 2,
      'pageSize': 10,
      'count': 42,
      'totalPages': 5,
      'data': [
        {'id': 900, 'transactionType': 'CapitalDeposit', 'amount': 100.0},
      ],
    });

    final merged = statement.copyWithMoreEntries(nextPage);
    expect(merged.entries.data.length, 5);
    expect(merged.entries.pageIndex, 2);
    // بيانات المساهم والإجماليات ما بتتغيرش مع تحميل صفحة جديدة.
    expect(merged.shareholder, statement.shareholder);
    expect(merged.accruedProfit, statement.accruedProfit);
  });
}
