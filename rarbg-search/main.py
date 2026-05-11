import secrets
import sqlite3
import urllib.parse
from fastapi import FastAPI, Request, Depends, HTTPException, status
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.security import HTTPBasic, HTTPBasicCredentials

app = FastAPI()
templates = Jinja2Templates(directory="templates")
security = HTTPBasic()

# Register urlencode filter for templates
templates.env.filters["urlencode"] = lambda s: urllib.parse.quote_plus(str(s))

# --- CONFIGURATION ---
USER_NAME = "charan"
USER_PASS = "Infme@feb21"

def get_current_user(credentials: HTTPBasicCredentials = Depends(security)):
    is_correct_username = secrets.compare_digest(credentials.username, USER_NAME)
    is_correct_password = secrets.compare_digest(credentials.password, USER_PASS)
    if not (is_correct_username and is_correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username

def get_db():
    # check_same_thread=False is required for SQLite + FastAPI
    conn = sqlite3.connect('rarbg_db.sqlite', check_same_thread=False)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

# --- ROUTES ---

@app.get("/", response_class=HTMLResponse)
async def index(request: Request, db=Depends(get_db), user=Depends(get_current_user)):
    # [cite_start]Fetch unique categories for the dropdown 
    cats = db.execute("SELECT DISTINCT cat FROM items WHERE cat IS NOT NULL ORDER BY cat").fetchall()
    categories = [row['cat'] for row in cats]
    return templates.TemplateResponse("index.html", {"request": request, "categories": categories, "query": ""})

@app.get("/search", response_class=HTMLResponse)
async def search(
    request: Request, 
    q: str = "", 
    cat: str = "All", 
    sort: str = "dt", 
    order: str = "desc",
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    # Refresh category list
    cats_db = db.execute("SELECT DISTINCT cat FROM items WHERE cat IS NOT NULL ORDER BY cat").fetchall()
    categories = [row['cat'] for row in cats_db]
    
    # [cite_start]1. Base Query - Handle empty search terms 
    search_query = f"%{q}%" if q else "%"
    sql = "SELECT title, hash, size, cat, dt, imdb FROM items WHERE title LIKE ?"
    params = [search_query]
    
    # [cite_start]2. Category Filter [cite: 3]
    if cat != "All":
        sql += " AND cat = ?"
        params.append(cat)
    
    # [cite_start]3. Dynamic Sorting (Whitelist columns to prevent SQL injection and errors) [cite: 2, 3]
    allowed_sorts = {"title": "title", "size": "size", "dt": "dt"}
    sort_column = allowed_sorts.get(sort, "dt")
    direction = "ASC" if order == "asc" else "DESC"
    
    sql += f" ORDER BY {sort_column} {direction} LIMIT 100"
    
    try:
        results = db.execute(sql, params).fetchall()
    except Exception as e:
        print(f"SQL Error: {e}")
        results = []
        
    return templates.TemplateResponse("index.html", {
        "request": request, 
        "results": results, 
        "query": q, 
        "selected_cat": cat,
        "categories": categories,
        "current_sort": sort,
        "current_order": order
    })
