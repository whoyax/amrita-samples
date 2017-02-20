<?php

require('interfaces.php');
require('product.php');
require('order.php');
require('discountManager.php');
require('discounts.php');


$order = new Order(array(
	new Product('A', 1200),
	new Product('B', 1400),
	new Product('B', 1400),
	new Product('A', 1200),
	new Product('A', 1200),
	new Product('C', 1500),
	new Product('D', 1600),
	new Product('E', 1700),
	new Product('E', 1700),
	new Product('E', 1700),
	new Product('F', 1800),
	new Product('G', 1900),
	new Product('H', 2000),
	new Product('I', 2100),
	new Product('J', 2200),
	new Product('K', 2300),
	new Product('L', 2400),
	new Product('M', 2500),
	));

$manager = new DiscountManager(array(
	new DiscountProductSet(array('A', 'B'), 10),
	new DiscountProductSet(array('D', 'E'), 5),
	new DiscountProductSet(array('E', 'F', 'G'), 5),
	new DiscountVariantProductSet('A', array('K', 'L', 'M'), 5),
	new DiscountByCount(
		array(
			3 => 5,
			4 => 10,
			5 => 20),
		array('A','C')
	)));


$manager->setOrder($order);
$manager->applyDiscounts();

$order->printItemsPrice();