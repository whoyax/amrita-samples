<?php

abstract class AbstractDiscount implements IDiscount {

	protected $manager;
	protected $discount;

	public function setManager(IDiscountManager $manager)
	{
		$this->manager = $manager;
	}

	public function setDiscount($discount)
	{
		$this->discount = $discount;
	}

	protected function searchTypedProduct($type, Array $items)
	{
		foreach($items as $item)
		{
			if($item->getType()===$type)
			{
				return $item;
			}
		}

		return false;
	}

	protected function saveProductsDiscounts(Array $products, $discount)
	{
		foreach ($products as $product) {
			$this->manager->saveDiscountForProduct($product, $discount);
		}
	}

	protected function markUsedProducts(Array $products)
	{
		foreach ($products as $product) {
			$this->manager->markUsedItem($product);
		}
	}
}



class DiscountProductSet extends AbstractDiscount {

	private $types = array();

	public function __construct(Array $types, $discount)
	{
		foreach($types as $type)
		{
			$this->addProductType($type);
		}
		$this->setDiscount($discount);
	}

	public function addProductType($type)
	{
		$this->types[] = $type;
	}

	public function setDiscount($discount)
	{
		$this->discount = $discount;
	}

	public function calculate(Array $items)
	{
		$typeCount = count($this->types);
		$products = array();
		$last = null;
		$first = null;

		while($first = $this->searchTypedProduct($this->types[0], $items))
		{
			if ($first === $last) break;

			$products = array($first);

			for($i=1; $i < $typeCount; $i++)
			{
				if($product = $this->searchTypedProduct($this->types[$i], $items))
				{
					$products[] = $product;
				}
			}

			if(count($products)==$typeCount)
			{
				$this->markUsedProducts($products);
				$this->saveProductsDiscounts($products, $this->discount);
				$items = $this->manager->getUnusedItems();
			}

			$products = array();
			$last = $first;
		}
	}
}




class DiscountVariantProductSet extends AbstractDiscount {

	private $mainType = '';
	private $types = array();

	public function __construct($mainType, Array $types, $discount)
	{
		$this->setMainType($mainType);
		foreach($types as $type)
		{
			$this->addSecondType($type);
		}
		$this->types = $types;
		$this->setDiscount($discount);
	}

	public function setMainType($type)
	{
		$this->mainType = $type;
	}

	public function addSecondType($type)
	{
		if(!in_array($type, $this->types))
		{
			$this->types[] = $type;
		}
	}

	public function setDiscount($discount)
	{
		$this->discount = $discount;
	}

	public function calculate(Array $items)
	{
		$last = null;
		$first = null;

		while($first = $this->searchTypedProduct($this->mainType, $items))
		{
			if ($first === $last) break;

			$product = null;

			foreach($this->types as $type)
			{
				if($product = $this->searchTypedProduct($type, $items))
				{
					$this->markUsedProducts(array($first, $product));
					$this->saveProductsDiscounts(array($product), $this->discount);
					$items = $this->manager->getUnusedItems();
					$last = $first;
					continue 2;
				}
			}
		}
	}
}


class DiscountByCount extends AbstractDiscount {

	private $excludes = array();
	private $discounts = array();

	public function __construct(Array $discounts, Array $excludes)
	{
		foreach($excludes as $exclude)
		{
			$this->addExclude($exclude);
		}
		$this->setDiscount($discounts);
	}

	public function addExclude($exclude)
	{
		if(!in_array($exclude, $this->excludes))
		{
			$this->excludes[] = $exclude;
		}
	}

	public function setDiscount($discounts)
	{
		$this->discounts = $discounts;
	}

	public function calculate(Array $items)
	{
		foreach ($items as $key => $item)
		{
			if(in_array($item->getType(), $this->excludes))
			{
				unset($items[$key]);
			}
		}

		$count = count($items);

		if (isset($this->discounts[$count]))
		{
			$this->markUsedProducts($items);
			$this->saveProductsDiscounts($this->manager->getAllItems(), $this->discounts[$count]);
		}
	}
}