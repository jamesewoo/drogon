import os

from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

drogon_home = os.environ['DROGON_HOME']
server_home = '{}/src/drogon-server'.format(drogon_home)
scripts_dir = '{}/scripts'.format(drogon_home)

default_args = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': datetime.now(),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2016, 1, 1),
}

dag = DAG('deploy_drogon', default_args=default_args, schedule_interval=timedelta(days=1))

t1 = BashOperator(
    task_id='deploy_runtime',
    bash_command='{}/deploy_runtime.sh {}'.format(scripts_dir, drogon_home),
    dag=dag)

t2 = BashOperator(
    task_id='deploy_test',
    bash_command='{}/deploy_test.sh {}'.format(scripts_dir, drogon_home),
    dag=dag)

t3 = BashOperator(
    task_id='deploy_server',
    bash_command='{}/deploy_server.sh {}'.format(scripts_dir, server_home),
    dag=dag)

t4 = BashOperator(
    task_id='deploy_latest',
    bash_command='{}/deploy_latest.sh '.format(scripts_dir),
    dag=dag)

t1 >> t2
t2 >> [t3, t4]
