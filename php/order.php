<?php
class Order implements IOrder {
	private $items = array();
	private $discountValues = array();

	public function addItem(IProduct $product)
	{
		$this->items[] = $product;
	}

	public function getItems()
	{
		return $this->items;
	}

	public function __construct(Array $items = array())
	{
		foreach($items as $item)
		{
			$this->addItem($item);
		}
	}

	public function printItemsPrice()
	{
		$sum = 0;
		foreach($this->items as $key => $item)
		{
			$type = $item->getType();
			$price = $item->getPrice();
			$discount = $this->getDiscountForProduct($item);
			$discountPrice = $this->getDiscountPriceForProduct($item);
			$sum += $discountPrice;
			echo "{$key}. <b>{$type}</b> Price: {$price} Discount: <b>{$discount}%</b> DiscountPrice: {$discountPrice} <br />";
		}

		echo "Sum: {$sum}";
	}

	public function getDiscountForProduct(Iproduct $product)
	{
		$id = $product->getId();
		if (isset($this->discountValues[$id]))
		{
			return $this->discountValues[$id];
		}
		return 0;
	}

	public function setDiscountForProduct(Iproduct $product, $discount)
	{
		$this->discountValues[$product->getId()] = $discount;
	}


	public function getDiscountPriceForProduct(Iproduct $product)
	{
		if($discount = $this->getDiscountForProduct($product))
		{
			$realDiscount = $discount/100;
			$discountPrice = $product->getPrice() - $product->getPrice()*$realDiscount;
			return $discountPrice;
		}
		return $product->getPrice();
	}
}