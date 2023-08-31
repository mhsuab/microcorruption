# New Orleans

The program asks for password and unlocks the door if the password is correct.

`<main>` function will generate a password w/ `<create_password>` and compare it with password in the input w/ `<check_password>`.

<details>
<summary>Pseudo C Code</summary>
    ```c
    void main() {
        char *password = create_password();
        puts("Enter the password to continue");
        char *input = get_password();
        if (check_password(password, input)) {
            puts("Access Granted!");
            unlock_door();
        } else {
            puts("Invalid password; try again.");
        }
        return;
    }
    ```
</details>


Therefore, break after the call to `<create_password>`, `@ 4440`,  and check the value of `r15` to get the password.

Alternatively, break at `<check_password>` and check `r14` (to get the real password).

<!-- solution: {'level_id': 2, 'input': '40674f5d256e37;'} -->
