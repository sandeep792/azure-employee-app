import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { Users, Building2, Briefcase, Search } from 'lucide-react'
import './index.css'

// Mock Data for demonstration if backend isn't connected
const MOCK_EMPLOYEES = [
  { id: '1', name: 'Alice Johnson', department: 'Engineering', role: 'Senior Developer' },
  { id: '2', name: 'Bob Smith', department: 'Product', role: 'Product Manager' },
  { id: '3', name: 'Charlie Brown', department: 'Design', role: 'UI/UX Designer' },
  { id: '4', name: 'Diana Ross', department: 'Engineering', role: 'DevOps Engineer' },
  { id: '5', name: 'Evan Wright', department: 'Marketing', role: 'Content Strategist' },
]

function App() {
  const [employees, setEmployees] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')

  useEffect(() => {
    async function fetchEmployees() {
      try {
        const res = await fetch('/api/getEmployees')
        if (res.ok) {
          const data = await res.json()
          setEmployees(data)
        } else {
          console.warn("Failed to fetch from backend, using mock data")
          setEmployees(MOCK_EMPLOYEES)
        }
      } catch (e) {
        console.warn("Error fetching, using mock data", e)
        setEmployees(MOCK_EMPLOYEES)
      } finally {
        setLoading(false)
      }
    }

    // Simulate network delay for effect
    setTimeout(fetchEmployees, 1000)
  }, [])

  const filteredEmployees = employees.filter(emp =>
    emp.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    emp.department.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const containerVariants = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0 }
  }

  return (
    <div className="container">
      <motion.header
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        style={{ marginBottom: '3rem', textAlign: 'center', paddingTop: '2rem' }}
      >
        <h1 style={{ fontSize: '2.5rem', marginBottom: '1rem', background: 'linear-gradient(to right, #38bdf8, #818cf8)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
          Employee Directory
        </h1>
        <p style={{ color: 'var(--text-secondary)' }}>manage and view your organization's talent</p>
      </motion.header>

      <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '2rem' }}>
        <div className="glass-panel" style={{ display: 'flex', alignItems: 'center', padding: '0.5rem 1rem', width: '100%', maxWidth: '500px' }}>
          <Search size={20} color="var(--text-secondary)" />
          <input
            type="text"
            placeholder="Search by name or department..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{
              background: 'transparent',
              border: 'none',
              outline: 'none',
              color: 'var(--text-primary)',
              marginLeft: '0.5rem',
              width: '100%',
              fontSize: '1rem'
            }}
          />
        </div>
      </div>

      {loading ? (
        <motion.div
          animate={{ opacity: [0.5, 1, 0.5] }}
          transition={{ repeat: Infinity, duration: 1.5 }}
          style={{ textAlign: 'center', color: 'var(--text-secondary)' }}
        >
          Loading employees...
        </motion.div>
      ) : (
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="show"
          style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '1.5rem' }}
        >
          {filteredEmployees.map((emp) => (
            <motion.div
              key={emp.id}
              variants={itemVariants}
              className="glass-panel"
              style={{ padding: '1.5rem', position: 'relative', overflow: 'hidden' }}
              whileHover={{ scale: 1.02, backgroundColor: 'rgba(30, 41, 59, 0.8)' }}
            >
              <div style={{ position: 'absolute', top: 0, left: 0, width: '4px', height: '100%', background: 'linear-gradient(to bottom, var(--accent), #818cf8)' }}></div>

              <div style={{ display: 'flex', alignItems: 'center', marginBottom: '1rem' }}>
                <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: 'rgba(56, 189, 248, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginRight: '1rem' }}>
                  <Users size={24} color="var(--accent)" />
                </div>
                <div>
                  <h3 style={{ fontSize: '1.25rem' }}>{emp.name}</h3>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginTop: '0.25rem' }}>
                    <Briefcase size={14} color="var(--text-secondary)" />
                    <span style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>{emp.role}</span>
                  </div>
                </div>
              </div>

              <div style={{ borderTop: '1px solid var(--glass-border)', paddingTop: '1rem', marginTop: '1rem' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <Building2 size={16} color="var(--text-secondary)" />
                  <span style={{ color: 'var(--text-secondary)' }}>{emp.department}</span>
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>
      )}
    </div>
  )
}

export default App
