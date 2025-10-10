<script setup>
import { onMounted, ref } from 'vue'
let users = ref([])
const getUser = () => {
  fetch('http://localhost:8080/users', {
    method: 'GET', // optional, GET is default
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.json()
    })
    .then((data) => {
      users.value = data
    })
    .catch((error) => {
      console.error('Error fetching users:', error)
    })
}

onMounted(() => {
  getUser()
})
</script>

<template>
  <div class="user-list">
    <h2>User List</h2>
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Email</th>
          <th>Phone</th>
          <th>Verified</th>
          <th>Provider</th>
          <th>First Name</th>
          <th>Last Name</th>
          <th>Nickname</th>
          <th>Card ID</th>
          <th>Birthday</th>
          <th>Age</th>
          <th>Sex</th>
          <th>Face Verify</th>
          <th>Behavior Score</th>
          <th>Blacklist</th>
          <th>Status</th>
          <th>Version</th>
          <th>Role</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="user.userId">
          <td>{{ user.userId }}</td>
          <td>{{ user.email }}</td>
          <td>{{ user.phoneNumber }}</td>
          <td>{{ user.isVerify ? 'Yes' : 'No' }}</td>
          <td>{{ user.provider }}</td>
          <td>{{ user.firstname }}</td>
          <td>{{ user.lastname }}</td>
          <td>{{ user.nickname }}</td>
          <td>{{ user.cardId }}</td>
          <td>{{ user.birthday }}</td>
          <td>{{ user.age }}</td>
          <td>{{ user.sex }}</td>
          <td>{{ user.faceVerify ? 'Yes' : 'No' }}</td>
          <td>{{ user.behaviorScore }}</td>
          <td>{{ user.isBlacklist ? 'Yes' : 'No' }}</td>
          <td>{{ user.accountStatus }}</td>
          <td>{{ user.version }}</td>
          <td>{{ user.role }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.user-list {
  padding: 2rem;
  max-width: 100%;
  overflow-x: auto;
}

h2 {
  text-align: center;
  margin-bottom: 1rem;
}

table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

th,
td {
  padding: 0.5rem;
  border: 1px solid var(--color-border);
  text-align: left;
}

th {
  background-color: var(--color-background-mute);
  font-weight: bold;
}

tr:nth-child(even) {
  background-color: var(--color-background-soft);
}

@media (min-width: 1024px) {
  .user-list {
    padding: 2rem calc(var(--section-gap) / 2);
  }

  table {
    font-size: 1rem;
  }
}
</style>
