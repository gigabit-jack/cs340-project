DROP PROCEDURE IF EXISTS sp_delete_orderItems;

DELIMITER //

CREATE PROCEDURE sp_delete_orderItems()
BEGIN
    DELETE FROM OrderItems;
END //

DELIMITER ;