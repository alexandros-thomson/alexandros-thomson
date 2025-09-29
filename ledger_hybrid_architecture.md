# 🏛️ **TEMPLE LEDGER: HYBRID ARCHITECTURE CANON**

## **📜 SACRED SCHEMA DESIGN**

### **Primary Audit Table (Source of Truth)**
```sql
-- The immutable chronicle of all Temple events
CREATE TABLE webhook_audit_log (
    id BIGSERIAL PRIMARY KEY,
    event_id UUID UNIQUE NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    event_type VARCHAR(50) NOT NULL, -- 'discord_role_change', 'discord_join', etc.
    user_id VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,     -- 'added', 'removed', 'joined', 'left'
    target VARCHAR(100),             -- role name, channel, etc.
    metadata JSONB,                  -- flexible additional data
    source VARCHAR(50) NOT NULL,     -- 'discord', 'patreon', 'manual'
    processed_at TIMESTAMPTZ,        -- when derived tables were updated
    
    -- Sacred indices for ritual queries
    INDEX idx_audit_user_timestamp (user_id, timestamp),
    INDEX idx_audit_event_type_timestamp (event_type, timestamp),
    INDEX idx_audit_processed (processed_at)
);
```

### **Derived State Tables (Operational Speed)**
```sql
-- Current Discord user roles (fast queries)
CREATE TABLE discord_user_current_roles (
    user_id VARCHAR(100) NOT NULL,
    role VARCHAR(100) NOT NULL,
    granted_at TIMESTAMPTZ NOT NULL,
    granted_by VARCHAR(100),
    last_verified TIMESTAMPTZ DEFAULT NOW(),
    
    PRIMARY KEY (user_id, role),
    INDEX idx_role_count (role)
);

-- Current Temple membership status
CREATE TABLE temple_member_status (
    user_id VARCHAR(100) PRIMARY KEY,
    discord_joined_at TIMESTAMPTZ,
    patreon_tier VARCHAR(50),
    total_roles_count INTEGER DEFAULT 0,
    last_activity TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, departed
    last_sync TIMESTAMPTZ DEFAULT NOW()
);
```

## **⚡ REAL-TIME SYNC TRIGGER (Event-Driven Canon)**

```sql
-- Sacred trigger function for maintaining derived state
CREATE OR REPLACE FUNCTION sync_current_roles()
RETURNS TRIGGER AS $$
BEGIN
    -- Handle Discord role changes
    IF NEW.event_type = 'discord_role_change' THEN
        IF NEW.action = 'added' THEN
            INSERT INTO discord_user_current_roles 
            (user_id, role, granted_at, granted_by)
            VALUES (NEW.user_id, NEW.target, NEW.timestamp, NEW.metadata->>'granted_by')
            ON CONFLICT (user_id, role) DO UPDATE SET
                granted_at = NEW.timestamp,
                last_verified = NOW();
                
        ELSIF NEW.action = 'removed' THEN
            DELETE FROM discord_user_current_roles 
            WHERE user_id = NEW.user_id AND role = NEW.target;
        END IF;
        
        -- Update role count
        UPDATE temple_member_status 
        SET total_roles_count = (
            SELECT COUNT(*) FROM discord_user_current_roles 
            WHERE user_id = NEW.user_id
        ),
        last_sync = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    
    -- Mark as processed
    UPDATE webhook_audit_log 
    SET processed_at = NOW() 
    WHERE id = NEW.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Bind the trigger to the audit table
CREATE TRIGGER trigger_sync_current_roles
    AFTER INSERT ON webhook_audit_log
    FOR EACH ROW EXECUTE FUNCTION sync_current_roles();
```

## **🔍 CONSISTENCY VALIDATION RITUAL**

```sql
-- Sacred query to detect drift between audit and derived state
CREATE OR REPLACE FUNCTION validate_ledger_consistency()
RETURNS TABLE(
    user_id VARCHAR(100),
    role VARCHAR(100), 
    issue_type VARCHAR(50),
    audit_state VARCHAR(20),
    derived_state VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    WITH audit_current_roles AS (
        SELECT DISTINCT 
            wal.user_id,
            wal.target as role
        FROM webhook_audit_log wal
        WHERE wal.event_type = 'discord_role_change'
          AND wal.action = 'added'
          AND NOT EXISTS (
              SELECT 1 FROM webhook_audit_log wal2
              WHERE wal2.user_id = wal.user_id
                AND wal2.target = wal.target
                AND wal2.event_type = 'discord_role_change'
                AND wal2.action = 'removed'
                AND wal2.timestamp > wal.timestamp
          )
    )
    SELECT 
        COALESCE(acr.user_id, dcr.user_id) as user_id,
        COALESCE(acr.role, dcr.role) as role,
        CASE 
            WHEN acr.role IS NULL THEN 'missing_in_audit'
            WHEN dcr.role IS NULL THEN 'missing_in_derived'
            ELSE 'unknown'
        END as issue_type,
        CASE WHEN acr.role IS NOT NULL THEN 'present' ELSE 'missing' END as audit_state,
        CASE WHEN dcr.role IS NOT NULL THEN 'present' ELSE 'missing' END as derived_state
    FROM audit_current_roles acr
    FULL OUTER JOIN discord_user_current_roles dcr 
        ON acr.user_id = dcr.user_id AND acr.role = dcr.role
    WHERE acr.role IS NULL OR dcr.role IS NULL;
END;
$$ LANGUAGE plpgsql;
```

## **📊 GRAFANA MONITORING QUERIES**

### **Core Metrics (PromQL)**
```promql
# Current role distribution
sum by(role) (discord_user_role_count)

# Audit event rate
rate(webhook_audit_events_total[5m])

# Processing latency
histogram_quantile(0.95, webhook_processing_duration_seconds)

# Consistency check failures
increase(ledger_consistency_errors_total[5m])

# Unprocessed audit entries
webhook_audit_unprocessed_count
```

### **Alert Conditions**
```yaml
groups:
  - name: temple_ledger_health
    rules:
      - alert: LedgerSyncFailure
        expr: increase(ledger_sync_errors_total[5m]) > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Temple Ledger sync failures detected"
          
      - alert: ConsistencyDrift
        expr: ledger_consistency_check_failures > 0
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Audit and derived state have drifted"
          
      - alert: ProcessingBacklog
        expr: webhook_audit_unprocessed_count > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Audit processing is falling behind"
```

## **🔄 RECONCILIATION CRON RITUAL**

```bash
#!/bin/bash
# /opt/temple/scripts/ledger-consistency-check.sh
# Run every 15 minutes via cron

echo "🔍 Performing Sacred Consistency Ritual..."

# Check for inconsistencies
ISSUES=$(psql -tAc "SELECT COUNT(*) FROM validate_ledger_consistency();")

if [ "$ISSUES" -gt 0 ]; then
    echo "⚠️ Found $ISSUES consistency issues"
    
    # Log details for investigation
    psql -c "SELECT * FROM validate_ledger_consistency();" \
        >> /var/log/temple/consistency-issues.log
    
    # Send alert to monitoring
    curl -X POST "http://prometheus-pushgateway:9091/metrics/job/ledger-consistency" \
        --data "ledger_consistency_check_failures $ISSUES"
        
    # Auto-repair if count is low
    if [ "$ISSUES" -lt 10 ]; then
        echo "🔧 Attempting auto-repair..."
        # Rebuild derived tables from audit log
        psql -c "CALL rebuild_derived_state_from_audit();"
    fi
else
    echo "✅ Ledger consistency validated - all systems aligned"
    curl -X POST "http://prometheus-pushgateway:9091/metrics/job/ledger-consistency" \
        --data "ledger_consistency_check_failures 0"
fi
```

## **📈 OPERATIONAL DASHBOARDS**

### **Temple Health Overview**
- Current member count by status
- Role distribution pie chart
- Event processing rate (last 24h)
- Consistency check status

### **Audit Trail Analysis**
- Event volume by type over time
- Top users by activity
- Processing latency trends
- Failed processing events

### **Performance Monitoring**
- Database query performance
- Webhook response times
- Trigger execution duration
- Table sizes and growth trends

---

## **🎯 NEXT SACRED ACTIONS**

1. **Deploy Base Schema** - Establish tables and triggers
2. **Implement Consistency Checks** - Set up validation rituals
3. **Configure Monitoring** - Bind Grafana dashboards
4. **Test Failure Scenarios** - Verify auto-recovery works
5. **Document Runbooks** - Canonize operational procedures

*May your ledger remain eternally consistent and your queries eternally swift.* ⚖️✨