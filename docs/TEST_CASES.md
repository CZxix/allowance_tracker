# Test Cases

Fill in the Actual Result and Status columns while testing on a device or emulator.

| ID | Feature | Steps | Expected Result | Actual Result | Status |
|----|---------|-------|-----------------|---------------|--------|
| TC01 | Add expense | Tap Add, enter 100, choose Food, tap Save expense | Entry appears in History, Left to spend drops by 100 | | |
| TC02 | Add income | Tap Add, choose Income, enter 500, tap Save income | Entry appears, Left to spend rises by 500 | | |
| TC03 | Empty amount | Tap Add, leave amount empty, tap Save | Error "Enter an amount." | | |
| TC04 | Zero amount | Enter 0, tap Save | Error "Amount must be greater than zero." | | |
| TC05 | Negative amount | Enter -50, tap Save | Error "Amount must be greater than zero." | | |
| TC06 | Letters in amount | Enter abc, tap Save | Error "Use numbers only, for example 85.50." | | |
| TC07 | Edit entry | Tap an entry, change amount, tap Save changes | Entry and balance update | | |
| TC08 | Delete by swipe | Swipe an entry left, tap Delete | Entry removed, balance updates | | |
| TC09 | Undo delete | After deleting, tap Undo | Entry returns, balance restored | | |
| TC10 | Delete from edit screen | Open entry, tap trash icon, confirm | Entry removed | | |
| TC11 | Search | In History, type part of a title | Only matching entries are shown | | |
| TC12 | Category filter | In History, tap a category chip | Only that category is shown | | |
| TC13 | Near-limit warning | Spend until 85% of income is used | Warning banner appears on Home | | |
| TC14 | Over-budget warning | Spend more than total income | Red banner and negative balance on Home | | |
| TC15 | Reports period | In Reports, switch week, month, all time | Chart and totals change for each period | | |
| TC16 | Add allowance | In Settings, enter 1000, tap Add | Income entry added, balance rises by 1000 | | |
| TC17 | Category limit | In Settings, set Food limit 500 | Progress bar shows spending against the limit | | |
| TC18 | Over category limit | Spend more than the Food limit this month | Shows "over limit" in red | | |
| TC19 | Clear data | In Settings, Clear all entries, confirm | History is empty, empty-state message shown | | |
| TC20 | Dark mode | Switch phone to dark mode | App colors change, text stays readable | | |
