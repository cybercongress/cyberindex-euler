from flask import Flask
from cohort import set_query, get_data

app = Flask(__name__)

@app.route('/cohort_main')
def get_cohort():
    query = set_query()
    return get_data(query)

@app.route('/<category_type>=<typ>')
def get_cohort_by_1cat(category_type, typ):
    if category_type == 'register_source':
        query = set_query(register_source=typ)
    elif category_type == 'register_type':
        query = set_query(register_type=typ)
    elif category_type == 'action_type':
        query = set_query(action_type=typ)
    return get_data(query)

@app.route('/<category_type1>=<typ1>&<category_type2>=<typ2>')
def get_cohort_by_2cat(category_type1, category_type2, typ1, typ2):
    if category_type1 == 'register_source' and category_type2 == 'register_type':
        query = set_query(register_source=typ1, register_type=typ2)
    elif category_type1 == 'register_source' and category_type2 == 'action_type':
        query = set_query(register_source=typ1, action_type=typ2)
    elif category_type1 == 'register_type' and category_type2 == 'action_type':
        query = set_query(register_type=typ1, action_type=typ2)
    return get_data(query)

@app.route('/<category_type1>=<typ1>&<category_type2>=<typ2>&<category_type3>=<typ3>')
def get_cohort_by_3cat(category_type1, category_type2, category_type3, typ1, typ2, typ3):
    query = set_query(register_source=typ1, register_type=typ2, action_type=typ3)
    return get_data(query)

if __name__ == '__main__':
    app.run(host='0.0.0.0')