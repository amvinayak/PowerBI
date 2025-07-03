foreach (var table in Model.Tables)
{
    foreach (var partition in table.Partitions)
    {
        if (!string.IsNullOrEmpty(partition.Expression))
        {
            string oldExpr = partition.Expression;
            string newExpr = oldExpr;

            // Replace host
            newExpr = newExpr.Replace(
                "adb-182961467146.16.azuredatabricks.net",
                "adb-182961467146.6.azuredatabricks.net");

            // Replace path
            newExpr = newExpr.Replace(
                "sql/protocolv1/o/18297146/1213-055413-ztdurkbu/0701-054051-uegpi9zs",
                "sql/protocolv1/o/18297146/1213-055413-ztdurkbu");

            // Only update if anything changed
            if (newExpr != oldExpr)
            {
                partition.Expression = newExpr;
                Console.WriteLine($"Updated partition '{partition.Name}' in table '{table.Name}'");
            }
        }
    }
}
