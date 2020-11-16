import psycopg2
import pandas as pd
from datetime import date
from dateutil import rrule
import numpy as np

from config import *
from queries import *

def set_query(register_source=None, register_type=None, action_type=None):

    # One category query
    if (register_source and not register_type and not action_type):
        query = TAG.format(register_source)
    elif (not register_source and register_type and not action_type):
        query = REGISTER_TYPE.format(ACTIONS[register_type])
    elif (not register_source and not register_type and action_type):
        query = ACTION_TYPE.format(ACTIONS[action_type])
    # Two categories query
    elif (register_source and register_type and not action_type):
        query = TAG_REGISTER_TYPE.format(register_source, ACTIONS[register_type])
    elif (not register_source and register_type and action_type):
        query = REGISTER_TYPE_ACTION_TYPE.format(ACTIONS[action_type], ACTIONS[register_type])
    elif (register_source and not register_type and action_type):
        query = TAG_ACTION_TYPE.format(ACTIONS[action_type], register_source)
    # Three categories query
    elif (register_source and register_type and action_type):
        query = TAG_REGISTER_TYPE_ACTION_TYPE.format(ACTIONS[action_type],register_source, ACTIONS[register_type])

    # No category query
    else:
        query = "select * from cohorts"
    return query

def months_list_num():
    return list(range(rrule.rrule(rrule.MONTHLY, dtstart=date(2020, 4, 1), until=date.today()).count())) + [-1]

def months_list_df():
    df = pd.DataFrame(list(rrule.rrule(rrule.MONTHLY, dtstart=date(2020, 4, 1), until=date.today())), columns =['register_act_month'])
    df = df.set_index('register_act_month')
    return df


def get_connection():
    return psycopg2.connect(user=DATABASE_USER,
                              password=DATABASE_PASSWORD,
                              host= DATABASE_HOST,
                              port=DATABASE_PORT,
                              database=DATABASE_NAME)

def get_table(query, connection):
    df = pd.read_sql_query(query, connection)
    df['diff'] = np.where(df.first_act_type.isnull(), -1, df['diff'])
    df = df.drop(['register_act_type', 'first_act_type', 'tag'], axis=1)
    return df

def get_cohort_table(df, months_list_num, months_list):
    cohort_table = pd.pivot_table(df, values='subject', aggfunc='count', columns='diff', index='register_act_month', fill_value=0).reindex(months_list_num, axis=1, fill_value=0)
    cohort_table = pd.merge(months_list, cohort_table, left_index=True, right_index=True, how='outer').fillna(0)
    cohort_table = cohort_table.rename(columns={-1: "Missed"})
    cohort_table['Total'] = cohort_table.sum(axis=1)
    return cohort_table

def get_data(query):
    try:
        connection = get_connection()
        df = get_table(query, connection)
        cohort_table = get_cohort_table(df, months_list_num(), months_list_df())
        col_names = cohort_table.columns.tolist()
        col_names = list(map(str, col_names))
        cohort_table.index = cohort_table.index.map(str)
        dates = list(cohort_table.index.values)[::-1]
        data = cohort_table.values.tolist()
        data = data[::-1]
        return {
            "z": data,
            "x": col_names,
            "y": dates
        }
    except (Exception, psycopg2.Error) as error:
        print("Error while fetching data from PostgreSQL", error)

    finally:
        # closing database connection.
        if (connection):
            connection.close()

# cohort_ratio = round(cohort_table.divide(cohort_table.iloc[:,-1],
#                                          axis = 0) * 100, 2)