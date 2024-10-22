#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct _entry {
  char key[0x10];
  int16_t value;
} entry_t;

typedef struct _hash_table {
  int16_t count;
  int16_t bucket_num;
  int16_t bucket_size;
  entry_t **buckets;
  int16_t *buckets_count;
} hash_table_t;

void add_to_table(hash_table_t *, char[], int16_t);

hash_table_t *create_hash_table(int16_t bucket_num, int16_t bucket_size) {
  hash_table_t *table = malloc(0xa);
  table->count = 0;
  table->bucket_num = bucket_num;
  table->bucket_size = bucket_size;

  int16_t slot = 1 << bucket_num;
  table->buckets = malloc(2 * slot);
  table->buckets_count = malloc(2 * slot);

  for (int i = 0; i < (1 << bucket_num); ++i) {
    table->buckets[i] = malloc(sizeof(entry_t) * bucket_size);
    table->buckets_count[i] = 0;
  }

  return table;
}

int16_t hash(char key[]) {
  int16_t ret = 0;
  for (int i = 0; key[i]; ++i) {
    ret = 31 * (ret + (int16_t)key[i]);
  }
  return ret;
}

int16_t get_from_table(hash_table_t *table, char key[]) {
  int16_t hash_value = hash(key);
  int16_t t = hash_value & ((1 << table->bucket_num) - 1);

  for (int i = 0; i < table->buckets_count[t]; ++i) {
    if (!strcmp(table->buckets[t][i].key, key)) {
      return table->buckets[t][i].value;
    }
  }
  return -1;
}

void rehash(hash_table_t *table, int16_t bucket_num) {
  int16_t prev_bucket_num = table->bucket_num;
  entry_t **prev_buckets = table->buckets;
  int16_t *prev_bucket_count = table->buckets_count;

  table->bucket_num = bucket_num;
  table->count = 0;

  table->buckets = malloc(2 << bucket_num);
  table->buckets_count = malloc(2 << bucket_num);

  for (int16_t i = 0; i <= (1 << table->bucket_num); ++i) {
    table->buckets[i] = malloc(sizeof(entry_t) * table->bucket_size);
    table->buckets_count[i] = 0;
  }

  for (int i = 0; i < (1 << prev_bucket_num); ++i) {
    for (int j = 0; j < prev_bucket_count[i]; ++j) {
      add_to_table(table, prev_buckets[i][j].key, prev_buckets[i][j].value);
    }
    free(prev_buckets[i]);
  }

  free(prev_bucket_count);
  free(prev_buckets);
}

void add_to_table(hash_table_t *table, char key[], int16_t unk) {
  int16_t threshold = (table->bucket_size << table->bucket_num);
  if (threshold < 0)
    threshold += 3;
  threshold = threshold >> 2;

  if (table->count > threshold)
    rehash(table, table->bucket_num + 1);
  table->count += 1;

  int16_t value = hash(key);
  int16_t bucket_index = value & ((1 << table->bucket_num) - 1);
  int16_t current_bucket_count = table->buckets_count[bucket_index];
  table->buckets_count[bucket_index] += 1;

  int i = 0;
  char c = key[i];
  for (; i != 0xf && c; c = key[++i])
    table->buckets[bucket_index][current_bucket_count].key[i] = c;
  table->buckets[bucket_index][current_bucket_count].value = unk;
}
