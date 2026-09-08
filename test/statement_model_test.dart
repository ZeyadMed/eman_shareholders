import 'dart:convert';

import 'package:eman_shareholders/feature/statement/data/models/statement_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// نفس الـ `data` اللي السيرفر رجّعها فعلًا لـ `/api/shareholder/statement`.
const _realResponse = '''
{
  "shareholder": {
    "id": 116,
    "name": "test",
    "phoneNumber": "01152220257",
    "address": "6 October",
    "contributedAmount": 0.01,
    "ownedPercentage": 0,
    "companyPercentage": 0,
    "totalProfitReceived": 0,
    "accruedProfit": 0,
    "capitalTreasuryId": 13,
    "capitalTreasuryName": "احمد نقدي",
    "notes": "",
    "createdAt": "2026-09-02T12:20:43.2443566"
  },
  "totalCapitalDeposited": 0.01,
  "totalCapitalWithdrawn": 0,
  "totalProfitCapitalized": 0,
  "totalProfitDistributed": 0,
  "accruedProfit": 0,
  "entries": {
    "pageIndex": 1,
    "pageSize": 10,
    "count": 1,
    "totalPages": 1,
    "data": [
      {
        "id": 20512,
        "voucherNumber": "RCP-CAP-20260902122043277-b08bb2d2fea8487db607e9273298a8f2",
        "date": "2026-09-02T12:20:43.278318",
        "transactionType": "CapitalDeposit",
        "amount": 0.01,
        "companyShare": null,
        "shareholderShare": null,
        "capitalBalanceAfter": 0.01,
        "treasuryName": "احمد نقدي",
        "notes": ""
      }
    ]
  }
}
''';

void main() {
  test('بيقرأ ريسبونس كشف الحساب الحقيقي صح', () {
    final json = jsonDecode(_realResponse) as Map<String, dynamic>;
    final statement = StatementModel.fromJson(json);

    expect(statement.shareholder.name, 'test');
    expect(statement.shareholder.phoneNumber, '01152220257');
    expect(statement.shareholder.contributedAmount, 0.01);
    expect(statement.shareholder.capitalTreasuryName, 'احمد نقدي');
    expect(statement.totalCapitalDeposited, 0.01);

    expect(statement.entries.count, 1);
    expect(statement.entries.totalPages, 1);
    expect(statement.entries.hasMore, isFalse);

    final entry = statement.entries.data.single;
    expect(entry.id, 20512);
    expect(entry.transactionType, TransactionType.capitalDeposit);
    expect(entry.transactionType.isCredit, isTrue);
    expect(entry.amount, 0.01);
    // الحقول اللي بترجع null لازم تفضل null مش صفر.
    expect(entry.companyShare, isNull);
    expect(entry.shareholderShare, isNull);
    expect(entry.capitalBalanceAfter, 0.01);
  });

  test('ريسبونس ناقص ما بيقعش', () {
    final statement = StatementModel.fromJson(const {});
    expect(statement.shareholder.name, '');
    expect(statement.entries.data, isEmpty);
    expect(statement.accruedProfit, 0);
  });

  test('دمج صفحة حركات إضافية بيضيف مش بيستبدل', () {
    final json = jsonDecode(_realResponse) as Map<String, dynamic>;
    final first = StatementModel.fromJson(json);

    final secondPage = PaginatedEntriesModel.fromJson({
      'pageIndex': 2,
      'pageSize': 10,
      'count': 2,
      'totalPages': 2,
      'data': [
        {
          'id': 20513,
          'transactionType': 'ProfitDistribution',
          'amount': 5.0,
          'date': '2026-09-03T10:00:00',
        },
      ],
    });

    final merged = first.copyWithMoreEntries(secondPage);

    expect(merged.entries.data.length, 2);
    expect(merged.entries.data.first.id, 20512);
    expect(merged.entries.data.last.id, 20513);
    expect(merged.entries.pageIndex, 2);
    // بيانات المساهم والإجماليات ما بتتغيرش مع تحميل صفحة جديدة.
    expect(merged.shareholder.name, 'test');
    expect(merged.totalCapitalDeposited, 0.01);
  });
}
