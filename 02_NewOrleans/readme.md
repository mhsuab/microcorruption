# New Orleans

The program asks for password and unlocks the door if the password is correct.

`<main>` function will generate a password w/ `<create_password>` and compare it with password in the input using `<check_password>`.

<details>
  <summary>Pseudo C Code for <code>main</code></summary>

  ```c
  void main() {
    char *password = create_password();
    puts("Enter the password to continue");
    char *input = get_password();
    if (check_password(input)) {
      puts("Access Granted!");
      unlock_door();
    } else {
      puts("Invalid password; try again.");
    }
    return;
  }
  ```

</details>

## Dive into `<create_password>` and `<check_password>`
For both of the function, the `password` is stored at and used from a fixed address `0x2400`.


## Solution
Therefore, break after the call to `<create_password>`, `@ 4440`, and check the value at `0x2400` to get the password.

<!-- solution: {'level_id': 2, 'input': '40674f5d256e37;'} -->
