<?php

interface IDiscountManager {
	public function addDiscount(IDiscount $discount);
	public function markUsedItem(IProduct $product);
	public function getUnusedItems();
	public function setOrder(IOrder $order);
	public function applyDiscounts();
	public function saveDiscountForProduct(Iproduct $product, $discount);
}

interface IProduct {
	public function getId();
	public function getPrice();
	public function getType();
}

interface IOrder {
	public function getDiscountForProduct(Iproduct $product);
	public function setDiscountForProduct(Iproduct $product, $discount);
	public function getDiscountPriceForProduct(Iproduct $product);
	public function addItem(IProduct $product);
	public function getItems();
}

interface IDiscount {
	public function calculate(Array $items);
	public function setManager(IDiscountManager $manager);
	public function setDiscount($discount);
}