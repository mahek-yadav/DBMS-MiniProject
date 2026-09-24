let currentQueryId = null;
let currentTable = null;
let currentSql = '';
let allQueries = [];
const allTables = ['donor', 'blood_bank', 'donation', 'hospital', 'blood_unit', 'hospital_request'];

document.addEventListener('DOMContentLoaded', () => {
    fetchQueries();
    fetchStats();
    renderTableList();

    document.getElementById('searchInput').addEventListener('input', (e) => {
        filterQueries(e.target.value);
    });

    document.getElementById('runBtn').addEventListener('click', () => {
        if (currentQueryId) {
            runQuery(currentQueryId);
        } else if (currentTable) {
            runTableQuery(currentTable);
        }
    });

    const copyBtn = document.getElementById('copyQueryBtn');
    if (copyBtn) {
        copyBtn.addEventListener('click', handleCopyQuery);
    }
});

async function fetchQueries() {
    try {
        const response = await fetch('/api/queries');
        if (response.ok) {
            allQueries = await response.json();
        } else {
            throw new Error('API request failed');
        }
    } catch (error) {
        console.warn('Backend API /api/queries not reachable, falling back to local query data:', error);
        if (typeof window !== 'undefined' && window.queries) {
            allQueries = window.queries;
        }
    }

    renderQueryList(allQueries);

    // Select Query 1 by default on load if available
    if (allQueries.length > 0 && !currentQueryId && !currentTable) {
        const firstItem = document.querySelector('.query-item');
        selectQuery(allQueries[0], { currentTarget: firstItem });
    }
}

async function fetchStats() {
    try {
        const response = await fetch('/api/stats');
        if (!response.ok) throw new Error('API failed');
        const stats = await response.json();
        document.getElementById('statDonors').textContent = stats.donors;
        document.getElementById('statUnits').textContent = stats.units;
        document.getElementById('statHospitals').textContent = stats.hospitals;
        document.getElementById('statRequests').textContent = stats.requests;
    } catch (error) {
        console.warn('Error fetching stats:', error);
    }
}

function renderQueryList(queries) {
    const list = document.getElementById('queryList');
    list.innerHTML = '';

    queries.forEach(q => {
        const item = document.createElement('div');
        item.className = 'query-item';
        if (q.id === currentQueryId) item.classList.add('active');
        
        item.innerHTML = `
            <strong><span class="q-pill">Q${q.id}</span> Query ${q.id}</strong>
            <span>${q.question}</span>
        `;
        
        item.addEventListener('click', (event) => selectQuery(q, event));
        list.appendChild(item);
    });
}

function filterQueries(searchTerm) {
    const term = searchTerm.toLowerCase().trim();
    const filtered = allQueries.filter(q => 
        q.question.toLowerCase().includes(term) || 
        q.id.toString() === term ||
        (q.sql && q.sql.toLowerCase().includes(term))
    );
    renderQueryList(filtered);
}

function renderTableList() {
    const list = document.getElementById('tableList');
    list.innerHTML = '';

    allTables.forEach(t => {
        const item = document.createElement('div');
        item.className = 'query-item';
        
        item.innerHTML = `<strong><span class="tbl-pill">TABLE</span> ${t}</strong>`;
        
        item.addEventListener('click', (event) => selectTable(t, event));
        list.appendChild(item);
    });
}

function selectQuery(query, event) {
    currentQueryId = query.id;
    currentTable = null;
    currentSql = query.sql;
    
    // Update active state in sidebar
    document.querySelectorAll('.query-item').forEach(el => el.classList.remove('active'));
    if (event && event.currentTarget) {
        event.currentTarget.classList.add('active');
    }

    // Update main header and action bar
    const heroTag = document.getElementById('queryHeroTag');
    if (heroTag) heroTag.textContent = `Business Query Q${query.id}`;
    document.getElementById('questionTitle').textContent = `Q${query.id}: ${query.question}`;
    document.getElementById('actionBar').style.display = 'flex';
    
    // Display solution query immediately
    displaySolutionQuery(query.sql, `Query ${query.id}`);

    // Reset table output until user clicks Run
    document.getElementById('resultsCard').style.display = 'none';
    document.getElementById('tableHead').innerHTML = '';
    document.getElementById('tableBody').innerHTML = '';
    
    const statusMsg = document.getElementById('statusMessage');
    statusMsg.textContent = 'Click "Execute Query" to run in PostgreSQL.';
    statusMsg.style.color = 'var(--text-muted)';
    const statusDot = document.getElementById('statusDot');
    if (statusDot) {
        statusDot.style.backgroundColor = '#10b981';
        statusDot.style.boxShadow = '0 0 8px #10b981';
    }
}

function selectTable(tableName, event) {
    currentTable = tableName;
    currentQueryId = null;
    const sql = `SELECT * FROM ${tableName} LIMIT 100;`;
    currentSql = sql;
    
    // Update active state in sidebar
    document.querySelectorAll('.query-item').forEach(el => el.classList.remove('active'));
    if (event && event.currentTarget) {
        event.currentTarget.classList.add('active');
    }

    // Update main header and action bar
    const heroTag = document.getElementById('queryHeroTag');
    if (heroTag) heroTag.textContent = `Raw Database Table`;
    document.getElementById('questionTitle').textContent = `View Table: ${tableName}`;
    document.getElementById('actionBar').style.display = 'flex';
    
    // Display solution query
    displaySolutionQuery(sql, `Table: ${tableName}`);

    // Reset table output until user clicks Run
    document.getElementById('resultsCard').style.display = 'none';
    document.getElementById('tableHead').innerHTML = '';
    document.getElementById('tableBody').innerHTML = '';
    
    const statusMsg = document.getElementById('statusMessage');
    statusMsg.textContent = 'Click "Execute Query" to inspect records.';
    statusMsg.style.color = 'var(--text-muted)';
    const statusDot = document.getElementById('statusDot');
    if (statusDot) {
        statusDot.style.backgroundColor = '#10b981';
        statusDot.style.boxShadow = '0 0 8px #10b981';
    }
}

function displaySolutionQuery(sql, badgeText) {
    const card = document.getElementById('solutionQueryCard');
    const codeEl = document.getElementById('solutionQueryCode');
    const badgeEl = document.getElementById('queryBadge');
    
    if (badgeEl && badgeText) {
        badgeEl.textContent = badgeText;
    }
    
    currentSql = sql;
    card.style.display = 'block';

    const formatted = formatSQL(sql);
    codeEl.innerHTML = highlightSQL(formatted);
}

function formatSQL(sql) {
    if (!sql) return '';
    let formatted = sql.trim();
    
    // Insert line breaks before major SQL clauses for clean multiline display
    if (!formatted.includes('\n')) {
        formatted = formatted
            .replace(/\s+(FROM)\s+/gi, '\nFROM ')
            .replace(/\s+(WHERE)\s+/gi, '\nWHERE ')
            .replace(/\s+((?:LEFT\s+|RIGHT\s+|INNER\s+|FULL\s+)?JOIN)\s+/gi, '\n$1 ')
            .replace(/\s+(GROUP\s+BY)\s+/gi, '\nGROUP BY ')
            .replace(/\s+(HAVING)\s+/gi, '\nHAVING ')
            .replace(/\s+(ORDER\s+BY)\s+/gi, '\nORDER BY ')
            .replace(/\s+(LIMIT)\s+/gi, '\nLIMIT ');
    }
    return formatted;
}

function highlightSQL(sql) {
    if (!sql) return '';

    // Escape HTML first
    let text = sql
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');

    // Highlight strings
    text = text.replace(/'([^'\\]*(?:\\.[^'\\]*)*)'/g, '<span class="sql-str">\'$1\'</span>');

    // Highlight functions
    text = text.replace(/\b(COUNT|SUM|AVG|MAX|MIN|COALESCE|ROUND)\b/gi, (match) => {
        return `<span class="sql-fn">${match}</span>`;
    });

    // Highlight SQL Keywords
    const keywords = [
        'SELECT', 'DISTINCT', 'FROM', 'WHERE', 'AND', 'OR', 'NOT',
        'IN', 'EXISTS', 'BETWEEN', 'LIKE', 'ORDER BY', 'GROUP BY',
        'HAVING', 'LIMIT', 'LEFT JOIN', 'RIGHT JOIN', 'INNER JOIN',
        'FULL JOIN', 'JOIN', 'ON', 'AS', 'ASC', 'DESC', 'IS', 'NULL',
        'UNION', 'ALL', 'CASE', 'WHEN', 'THEN', 'ELSE', 'END'
    ];
    const regex = new RegExp(`\\b(${keywords.join('|')})\\b`, 'gi');
    text = text.replace(regex, (match) => {
        return `<span class="sql-keyword">${match}</span>`;
    });

    // Highlight numbers (outside tags)
    text = text.replace(/(?<![a-zA-Z_#])\b(\d+)\b(?![^<]*>)/g, '<span class="sql-num">$1</span>');

    return text;
}

function handleCopyQuery() {
    if (!currentSql) return;

    navigator.clipboard.writeText(currentSql).then(() => {
        const copyBtnText = document.getElementById('copyBtnText');
        if (copyBtnText) {
            const orig = copyBtnText.textContent;
            copyBtnText.textContent = 'Copied!';
            setTimeout(() => {
                copyBtnText.textContent = orig;
            }, 2000);
        }
    }).catch(err => {
        console.error('Failed to copy query:', err);
    });
}

async function runTableQuery(tableName) {
    executeFetch(`/api/table/${tableName}`);
}

async function runQuery(id) {
    executeFetch(`/api/query/${id}`);
}

async function executeFetch(url) {
    const statusMsg = document.getElementById('statusMessage');
    const statusDot = document.getElementById('statusDot');
    const tableHead = document.getElementById('tableHead');
    const tableBody = document.getElementById('tableBody');
    const resultsCard = document.getElementById('resultsCard');
    const rowCountBadge = document.getElementById('rowCountBadge');
    
    statusMsg.textContent = 'Executing query in PostgreSQL...';
    statusMsg.style.color = 'var(--text-muted)';
    if (statusDot) {
        statusDot.style.backgroundColor = '#f59e0b';
        statusDot.style.boxShadow = '0 0 8px #f59e0b';
    }
    resultsCard.style.display = 'block';
    tableHead.innerHTML = '';
    tableBody.innerHTML = '';

    try {
        const response = await fetch(url);
        const result = await response.json();

        if (result.error) {
            statusMsg.textContent = `Error: ${result.error}`;
            statusMsg.style.color = '#ef4444';
            if (statusDot) {
                statusDot.style.backgroundColor = '#ef4444';
                statusDot.style.boxShadow = '0 0 8px #ef4444';
            }
            if (rowCountBadge) rowCountBadge.textContent = 'Error';
            return;
        }

        // Keep solution query updated with the executed SQL from server
        if (result.sql) {
            displaySolutionQuery(result.sql, currentQueryId ? `Query ${currentQueryId}` : `Table ${currentTable}`);
        }

        const count = result.rowCount !== undefined ? result.rowCount : (result.data ? result.data.length : 0);
        statusMsg.textContent = `Returned ${count} row(s) successfully.`;
        statusMsg.style.color = '#10b981'; // vibrant green
        if (statusDot) {
            statusDot.style.backgroundColor = '#10b981';
            statusDot.style.boxShadow = '0 0 8px #10b981';
        }

        if (rowCountBadge) {
            rowCountBadge.textContent = `${count} row${count === 1 ? '' : 's'}`;
        }

        if (result.data && result.data.length > 0) {
            // Generate table headers
            const columns = Object.keys(result.data[0]);
            const headerRow = document.createElement('tr');
            columns.forEach(col => {
                const th = document.createElement('th');
                th.textContent = col.replace(/_/g, ' ');
                headerRow.appendChild(th);
            });
            tableHead.appendChild(headerRow);

            // Generate table rows
            result.data.forEach(row => {
                const tr = document.createElement('tr');
                columns.forEach(col => {
                    const td = document.createElement('td');
                    const val = row[col];
                    if (val === null || val === undefined) {
                        td.innerHTML = '<span class="val-null">null</span>';
                    } else if (col === 'blood_group') {
                        td.innerHTML = `<span class="blood-pill">${val}</span>`;
                    } else if (col === 'status') {
                        td.innerHTML = `<span class="status-badge badge-${val.toLowerCase()}">${val}</span>`;
                    } else if (typeof val === 'string' && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(val)) {
                        const d = new Date(val);
                        if (!isNaN(d)) {
                            const year = d.getFullYear();
                            const month = String(d.getMonth() + 1).padStart(2, '0');
                            const day = String(d.getDate()).padStart(2, '0');
                            td.textContent = `${year}-${month}-${day}`;
                        } else {
                            td.textContent = val;
                        }
                    } else {
                        td.textContent = val;
                    }
                    tr.appendChild(td);
                });
                tableBody.appendChild(tr);
            });
        } else {
            const tr = document.createElement('tr');
            const td = document.createElement('td');
            td.textContent = 'Query executed successfully. 0 rows returned.';
            td.style.color = 'var(--text-muted)';
            td.style.fontStyle = 'italic';
            tr.appendChild(td);
            tableBody.appendChild(tr);
        }

    } catch (error) {
        console.error('Error running query:', error);
        statusMsg.textContent = 'Failed to execute query against database.';
        statusMsg.style.color = '#ef4444';
        if (statusDot) {
            statusDot.style.backgroundColor = '#ef4444';
            statusDot.style.boxShadow = '0 0 8px #ef4444';
        }
        if (rowCountBadge) rowCountBadge.textContent = 'Failed';
    }
}
