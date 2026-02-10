const express = require('express');
const Transaction = require('../models/Transaction');

const router = express.Router();

// ──────────────────────────────────────────
// POST /api/transactions  — Add transaction
// ──────────────────────────────────────────
router.post('/', async (req, res) => {
  try {
    const { userId, category, title, amount, type, note, date } = req.body;

    const transaction = await Transaction.create({
      userId,
      category,
      title,
      amount,
      type: type || 'expense',
      note: note || '',
      date: date || Date.now(),
    });

    res.status(201).json({
      success: true,
      message: 'Transaction added successfully',
      transaction,
    });
  } catch (err) {
    console.error('Add transaction error:', err);
    res.status(500).json({ success: false, message: err.message || 'Server error' });
  }
});

// ──────────────────────────────────────────
// GET /api/transactions/:userId  — Get all transactions for user
// ──────────────────────────────────────────
router.get('/:userId', async (req, res) => {
  try {
    const transactions = await Transaction.find({ userId: req.params.userId })
      .sort({ date: -1 });

    // Calculate totals
    let totalIncome = 0;
    let totalExpense = 0;
    for (const t of transactions) {
      if (t.type === 'income') totalIncome += t.amount;
      else totalExpense += t.amount;
    }

    res.json({
      success: true,
      transactions,
      totalIncome,
      totalExpense,
      balance: totalIncome - totalExpense,
    });
  } catch (err) {
    console.error('Get transactions error:', err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ──────────────────────────────────────────
// GET /api/transactions/summary/:userId  — Category-wise summary
// ──────────────────────────────────────────
router.get('/summary/:userId', async (req, res) => {
  try {
    const summary = await Transaction.aggregate([
      { $match: { userId: require('mongoose').Types.ObjectId.createFromHexString(req.params.userId) } },
      {
        $group: {
          _id: { category: '$category', type: '$type' },
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { '_id.category': 1 } },
    ]);

    res.json({ success: true, summary });
  } catch (err) {
    console.error('Get summary error:', err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ──────────────────────────────────────────
// DELETE /api/transactions/:id  — Delete a transaction
// ──────────────────────────────────────────
router.delete('/:id', async (req, res) => {
  try {
    await Transaction.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Transaction deleted' });
  } catch (err) {
    console.error('Delete transaction error:', err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
