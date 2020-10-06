# auto_sub.sh

Skrypt służący do automatycznego dodawania zadań na klastrach zarządzanych przez system kolejkowy "slurm".

## Zasada działania

1. Skrypt odczytuje parametry zadania z pliku *input_file*.
2. Jeśli liczba zadań danego użytkownika o nazwie zawierającej *name_prefix* jest mniejsza od maksymalnej liczby jednoczesnych zadań to skrypt:
    a. kopiuje zawartość katalogu *template* do katalogu *case/numer_zadania*,
    b. odczytane parametry zapisuje w katalogu zadania w pliku o nazwie *case_input_file*,
    c. do skryptu uruchamiającego zadanie dodaje instrukcje, które po zakończeniu wykonywania zadania zapiszą otrzymany wynik do wspólnego pliku *output_file*,
    d. uruchamia skrypt zadania za pomocą komendy *sbatch*.

Zjawisko **Race Condition** nie występuje ponieważ instrukcje dodawane do skryptu startowego wymuszają sprawdzenie czy inny skrypt właśnie nie próbuje niczego zapisać.
Za "znacznik" zajętości służy link symboliczny, który tworzony jest w momencie rozpoczęcia zapisu i usuwany po nim.

**Uwaga:**

- Wszystkie pliku wejściowe/wyjściowe powinny zawierać nagłówki.
- Program uruchamiany przez skrypt zadania powinien odczytywać parametry zadania z pliku *case_input_file* a wynik (wraz z parametrami) zapisywać do pliku *case_output_file*.

Plik z ustawieniami powinien zawierać wartości zmiennych:

- name_prefix (podstawa nazwy zadania)
- input_file (nazwa pliku z parametrami dla poszczególnych zadań)
- output_file (nazwa pliku, w którym zapisane zostaną wyniki wszystkich zadań)
- case_input_file (nazwa pliku z parametrami dla danego zadania)
- case_output_file (nazwa pliku, w którym zapisane zostaną wyniki danego zadania)
- case_start (numer zadania z listy, od którego należy rozpocząć)
- case_end (numer zadania z listy, na którym należy skończyć)
- case_sim (maksymalna liczba jednoczesnych zadań)
- case_script (nazwa skryptu uruchamiającego pojedyncze zadanie)

## Przykład 1

Katalog "example_1" zawiera pliki, które można wykorzystać do uruchomienia przykładowego procesu.

# auto_sub_pkg.sh

Skrypt służący do automatycznego dodawania zadań na klastrach zarządzanych przez system kolejkowy "slurm".
Zadania dodawane są w "paczkach" co jest wygodne w przypadku kiedy trzeba wykonać bardzo dużo symulacji (np. w przypadku analiz Monte Carlo).

## Przykład 2

Katalog "example_2" zawiera pliki, które można wykorzystać do uruchomienia przykładowego procesu.

