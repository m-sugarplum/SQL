import math
import os
import pandas as pd
import psycopg2 as is_pies

# Excel sheet with card_indexes saved in 5 columns
cards_indexes_path = r"XXX"
sheet_name = 'karty'
column_names = ['col1', 'col2', 'col3', 'col4', 'col5']

data_frame = pd.read_excel(cards_indexes_path, sheet_name=sheet_name)
		
# Params to connect with profile DB:
db_params = {
	'dbname': 'XXX',
	'user': 'XXX',
	'password': 'XXX',
	'host': 'XXX',
	'port': 5432
}

# Connecting to the DB:
conn = is_pies.connect(**db_params)
cursor = conn.cursor()


def df_columns_to_lists(excel_columns):
	"""
	Takes a list with column names in Excel sheet that was converted to DataFrame (variable name: data_frame).
	Returns the final_list, which length = number of columns. 

	Each nested list contains values saved in a given column (for example: card indexes of column 1).
	"""
	final_list = [] 
	final_list_len = 0
	for column in excel_columns:
		data_list = data_frame[column].tolist()
		cleaned_list =  [str(int(index)) for index in data_list if not math.isnan(index)]
		final_list.append(cleaned_list)
		final_list_len += len(cleaned_list)
	return final_list

# Stores nested lists (1 for each Excel sheet column)
all_card_indexes = df_columns_to_lists(column_names)
indexes_without_a_card = []

all_card_ids = []	

def find_card_id(card_index):
	"""
	Takes a card index (string) and finds connected card ids in the database (PROFILE users.card).
	Returns a list of card ids.
	"""
	fetched_ids_cleaned = []
	query_card_id = "SELECT id FROM users.card c WHERE c.card_index = %s"

	cursor.execute(query_card_id, (card_index,))
	fetched_ids = cursor.fetchall()
	# print(fetched_ids)
	num_of_cards = len(fetched_ids)

	if num_of_cards != 1:
		if num_of_cards == 0:
			# print(f"Card index {card_index} doesn't have any card id attached")
			indexes_without_a_card.append(card_index)
				
		else:
			for num in range(num_of_cards):
				card_id = fetched_ids[num][0]
				fetched_ids_cleaned.append(card_id)
				# print(f"Card id {card_id} (connected with card index {card_index}) added to all_card_ids")	
	else:
		card_id = fetched_ids[0][0]
		fetched_ids_cleaned.append(card_id)

	return fetched_ids_cleaned
				
def save_card_ids(column_num, chunk):
	"""
	Takes a column number and a slice of indexes we want to process at a time.
	For example, save_card_ids(2, 1000) will take all indexes from column #2 and process them step by step, taking 1000 of them at a time.
	It creates a folder with column number and within it a subfolders with text files. 
	Each file stores ids (seperated by \n and a coma) of 1000 card indexes.
	"""
	directory_name = f"card_id_files/{column_num}"
	os.makedirs(directory_name, exist_ok=True)

	indexes_to_process = all_card_indexes[column_num-1].copy()
	print(f"There are {len(indexes_to_process)} card ids to save as a text file from column #{column_num}")
	iteration_num = len(indexes_to_process)//chunk

	for i in range(iteration_num + 1):
		if i == iteration_num:
			with open(f"card_id_files\{column_num}\{len(indexes_to_process)}_indexes_column_{column_num}_part{i + 1}.txt", 'a') as file:
				for indexes in range(len(indexes_to_process) + 1):
					if indexes_to_process:	
						current_card_index = indexes_to_process.pop()
						found_card_ids = find_card_id(current_card_index)
						if found_card_ids:
							for card_id in found_card_ids:			
								file.write(f"{card_id},\n")
								print(f"Saved card id {card_id} for card index {current_card_index}")
					else:	
						print('Finished')
		else:
			with open(f"card_id_files\{column_num}\{chunk}_indexes_column_{column_num}_part{i + 1}.txt", 'w') as file:
				for indexes in range(chunk):
					current_card_index = indexes_to_process.pop()
					found_card_ids = find_card_id(current_card_index)
					if found_card_ids:
						for card_id in found_card_ids:			
							file.write(f"{card_id},\n")
							print(f"Saved card id {card_id} for card index {current_card_index}")
					else:
						print(f"Card id not found for index no {current_card_index}")