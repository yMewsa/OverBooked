/**
 * Cloud Functions for Overbooked — Reading Stats Automation
 *
 * Trigger: Firestore onDocumentUpdated on users/{userId}/books/{bookId}
 * Purpose: Automatically update /users/{userId}/stats/summary whenever
 *          a book's status changes to 'read'.
 *
 * Uses Firebase Functions v2 (recommended for new projects).
 */

const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");

initializeApp();

/**
 * Listens for book document updates and increments reading statistics
 * when a book transitions to the 'read' status.
 */
exports.onBookStatusChanged = onDocumentUpdated(
  "users/{userId}/books/{bookId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Guard: only process actual status changes TO 'read'.
    if (!before || !after) return null;
    if (before.status === after.status) return null;
    if (after.status !== "read") return null;

    const userId = event.params.userId;
    const bookId = event.params.bookId;

    console.log(`Book "${bookId}" marked as read by user "${userId}".`);

    const db = getFirestore();
    const statsRef = db.doc(`users/${userId}/stats/summary`);

    // Safely extract page count — default to 0 if missing or invalid.
    const pageCount =
      typeof after.pageCount === "number" && after.pageCount > 0
        ? after.pageCount
        : 0;

    // Determine the completion date for monthly tracking.
    // Use the stored completedAt if available, otherwise use now.
    const now = new Date();
    let completedAt = now;

    if (after.completedAt && typeof after.completedAt.toDate === "function") {
      completedAt = after.completedAt.toDate();
    }

    const isCompletedThisMonth =
      completedAt.getFullYear() === now.getFullYear() &&
      completedAt.getMonth() === now.getMonth();

    // Build the atomic increment update.
    const statsUpdate = {
      booksRead: FieldValue.increment(1),
      pagesRead: FieldValue.increment(pageCount),
      lastUpdated: Timestamp.now(),
    };

    if (isCompletedThisMonth) {
      statsUpdate.pagesReadThisMonth = FieldValue.increment(pageCount);
    }

    // Use merge: true so the document is created if it doesn't exist yet.
    await statsRef.set(statsUpdate, { merge: true });

    console.log(
      `Stats updated: +1 book, +${pageCount} pages` +
      (isCompletedThisMonth ? `, +${pageCount} pages this month` : "")
    );

    return null;
  }
);
