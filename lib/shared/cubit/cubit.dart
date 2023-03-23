import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/todo_app/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/todo_app/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/todo_app/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';
import '../network/local/cache_helper.dart';


class AppCubit extends Cubit<AppStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get(contxt) => BlocProvider.of(contxt);

  int currentIndex = 0;
  List<Widget> screens =
  [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles =
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

 late Database database;
  late List<Map> newTasks = [];
  late List<Map> doneTasks = [];
  late List<Map> archivedTasks = [];

  void changeIndex(int index)
  {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }


  void createDatabase()  {
     openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database , version) {

        print('database is created');
        database
            .execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, time TEXT , title TEXT, date TEXT , status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error){
          print('Error when Create Table ${error.toString()}');
        });
      },
      onOpen: (database)
      {
        getDataFromDatabase(database);

        print('database is opened');
      },
    ).then((value)
     {
       database = value;
       emit(AppCreateDatabaseState());
     });
  }

   insertToDatabase({
    required String title,
    required String time,
    required String data,
  }) async {
    await database.transaction((txn) {
       return txn.rawInsert(
          'INSERT INTO tasks(title,date,time,status) VALUES("$title","$data","$time","new")'
      ).then((value)
      {
        print('$value inserted successfully');
        emit(AppInserteDatabaseState());

        getDataFromDatabase(database);
      }).catchError((error) {
        print('error when Inserting New Record ${error.toString()}');
      });
    });
  }
  void getDataFromDatabase (database)
  {
    emit(AppGetDatabaseLoadingState());
    
     database.rawQuery('SELECT * FROM tasks').then((value) {
        newTasks =[];
        doneTasks =[];
        archivedTasks =[];

       value.forEach((element)
       {

         if(element['status'] == 'new')
           newTasks.add(element);
         else if(element['status'] == 'done')
           doneTasks.add(element);
         else archivedTasks.add(element);


       });

       emit(AppGetDatabaseState());
     });
  }

  void updateData ({
  required String status,
  required int id,
}) async
  {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id],
   ).then((value)
    {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData ({

    required int id,
  }) async
  {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value)
    {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon =Icons.edit;

  void changeBottomSHeetState(
  {
  required bool? isShow,
  required IconData icon,
})
  {
    isBottomSheetShown = isShow!;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }

  bool isDark = false;


  void changeAppMode({required bool? formShared})
  {
    if(formShared != null)
    {
      isDark= formShared;
      emit(AppChangeModetState());
    }
    else
      {
        isDark =! isDark;
        CacheHelper.putBoolean(key: 'isDark', value: isDark).then((value)
        {
          emit(AppChangeModetState());
        });
      }


  }
}