# Syntax Highlighting Test

This is a test document to show off code highlighting.

## Python Example

```python
import asyncio
from dataclasses import dataclass
from typing import Optional, List

@dataclass
class User:
    name: str
    email: str
    age: Optional[int] = None

class UserService:
    def __init__(self, db_connection):
        self.db = db_connection
        self._cache = {}

    async def get_user(self, user_id: int) -> Optional[User]:
        """Fetch a user by ID, with caching."""
        if user_id in self._cache:
            return self._cache[user_id]

        query = "SELECT * FROM users WHERE id = ?"
        result = await self.db.execute(query, [user_id])

        if result:
            user = User(**result)
            self._cache[user_id] = user
            return user
        return None

    async def list_users(self, limit: int = 100) -> List[User]:
        results = await self.db.execute(
            f"SELECT * FROM users LIMIT {limit}"
        )
        return [User(**row) for row in results]

# Main entry point
async def main():
    print("Starting user service...")
    for i in range(10):
        if i % 2 == 0:
            print(f"Even number: {i}")

if __name__ == "__main__":
    asyncio.run(main())
```

## Shell Example

```shell
#!/bin/bash
for file in *.md; do
    echo "Processing $file"
    luajit markdown.lua "$file"
done
```

## Lua Example

```lua
local function fibonacci(n)
    if n <= 1 then return n end
    return fibonacci(n - 1) + fibonacci(n - 2)
end

for i = 1, 10 do
    print(string.format("fib(%d) = %d", i, fibonacci(i)))
end
```

> This is a blockquote to show that works too.

And some **bold** and *italic* text for good measure.
