import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late DateTime currentMonth;
  late List<DateTime> datesGrid;
  Map<DateTime, String> notes = {};

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    datesGrid = _generateDatesGrid(currentMonth);
  }

  List<DateTime> _generateDatesGrid(DateTime month) {
    int numDays = DateTime(month.year, month.month + 1, 0).day;
    int firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    List<DateTime> dates = [];

    DateTime previousMonth = DateTime(month.year, month.month - 1);
    int previousMonthLastDay =
        DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
    for (int i = firstWeekday; i > 0; i--) {
      dates.add(DateTime(previousMonth.year, previousMonth.month,
          previousMonthLastDay - i + 1));
    }

    for (int day = 1; day <= numDays; day++) {
      dates.add(DateTime(month.year, month.month, day));
    }

    int remainingBoxes = 42 - dates.length;
    for (int day = 1; day <= remainingBoxes; day++) {
      dates.add(DateTime(month.year, month.month + 1, day));
    }

    return dates;
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
      datesGrid = _generateDatesGrid(currentMonth);
    });
  }

  void _showNoteDialog(DateTime date) {
    String note = notes[date] ?? "";
    TextEditingController controller = TextEditingController(text: note);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, //height required by its children
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Notes for ${date.day}/${date.month}/${date.year}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Gap(10),
                TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: "Enter your note"),
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (notes.containsKey(date))
                      TextButton(
                        onPressed: () {
                          setState(() {
                            notes.remove(date);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          notes[date] = controller.text.trim();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => _changeMonth(-1)),
              Text('${_monthName(currentMonth.month)} ${currentMonth.year}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500)),
              IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => _changeMonth(1)),
            ],
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  7,
                  (index) => Text(
                        [
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat'
                        ][index],
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.blueGrey),
                      )),
            ),
          ),
          const Gap(12),
          Flexible(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7),
              itemCount: datesGrid.length,
              itemBuilder: (context, index) {
                DateTime date = datesGrid[index];
                bool isCurrentMonth = date.month == currentMonth.month;
                bool hasNote = notes.containsKey(date);
                return GestureDetector(
                  onTap: () => _showNoteDialog(date),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      backgroundColor: hasNote
                          ? Colors.amber
                          : (isCurrentMonth
                              ? Colors.white
                              : Colors.transparent),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: isCurrentMonth ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int monthNumber) {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][monthNumber - 1];
  }
}
