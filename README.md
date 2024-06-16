
# PhoneCommander

This is a Contact Management System built with a Node.js backend using Express and MongoDB, and a frontend using SwiftUI for macOS applications.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [File Structure](#file-structure)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Prerequisites

- Node.js and npm
- MongoDB
- Xcode (for SwiftUI development)

### Backend Setup

1. Clone the repository:

    ```sh
    git clone https://github.com/kmakieiev/PhoneCommander.git
    cd PhoneCommander
    ```

2. Install the required Node.js packages:

    ```sh
    cd server
    npm install
    ```

3. Start the MongoDB server:

    ```sh
    mongod
    ```

4. Start the Node.js server:

    ```sh
    npm start
    ```

### Frontend Setup

1. Open the project in Xcode:

    ```sh
    cd path/to/contact-management-system/ios
    open ContactManagementSystem.xcodeproj
    ```

2. Build and run the app on a simulator or a physical device.

## Usage

### Backend

- The backend server runs on `http://localhost:3000`.
- It provides a REST API to manage contacts stored in a MongoDB database.

### Frontend

- The SwiftUI app connects to the backend server to fetch, create, update, and delete contacts.
- The app provides a user interface to view, add, edit, and delete contacts, along with customization options for contact fields.

## API Endpoints

### GET /contacts

Fetch all contacts.

**Response:**

```json
[
  {
    "_id": "contact_id",
    "name": "Contact Name",
    "phone": "Contact Phone",
    "Email": "Contact Email",
    "Instagram": "Contact Instagram"
  },
  ...
]
```

### POST /contacts

Create a new contact.

**Request Body:**

```json
{
  "name": "Contact Name",
  "phone": "Contact Phone",
  "Email": "Contact Email",
  "Instagram": "Contact Instagram"
}
```

**Response:**

```json
{
  "_id": "contact_id",
  "name": "Contact Name",
  "phone": "Contact Phone",
  "Email": "Contact Email",
  "Instagram": "Contact Instagram"
}
```

### PUT /contacts/:id

Update a contact by ID.

**Request Body:**

```json
{
  "name": "Updated Name",
  "phone": "Updated Phone",
  "Email": "Updated Email",
  "Instagram": "Updated Instagram"
}
```

**Response:**

```json
{
  "_id": "contact_id",
  "name": "Updated Name",
  "phone": "Updated Phone",
  "Email": "Updated Email",
  "Instagram": "Updated Instagram"
}
```

### DELETE /contacts/:id

Delete a contact by ID.

**Response:**

- Status: 204 No Content

## File Structure

```sh
.
├── server
│   ├── index.js
│   └── package.json
├── ios
│   ├── ContentView.swift
│   ├── AddContactView.swift
│   ├── ContactDetailsView.swift
│   └── ViewController.swift
└── README.md
```

- **server/index.js**: Main server file with API endpoints.
- **ios/ContentView.swift**: Main SwiftUI view that lists contacts and provides options to add, edit, and delete.
- **ios/AddContactView.swift**: SwiftUI view to add new contacts.
- **ios/ContactDetailsView.swift**: SwiftUI view to show detailed information about a contact.
- **ios/ViewController.swift**: macOS view controller to manage contacts using AppKit.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

