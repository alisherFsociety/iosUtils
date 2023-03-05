//
//  ViewPager.swift
//  
//
//  Created by Alisher on 03.03.2023.
//

import UIKit

class MyViewPager: UIView {
    let scrollView = UIScrollView()
    let contentStackView = UIStackView()
    var delegate:ViewPagerDelegate?
    
    init() {
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        scrollView.keyboardDismissMode = .onDrag
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        self.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(contentStackView)
        
        
        
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .fill
        contentStackView.spacing = 0
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    
    func setViews(pages: [UIView]){
        contentStackView.arrangedSubviews.forEach { (view) in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for page in pages {
            contentStackView.addArrangedSubview(page)
            page.translatesAutoresizingMaskIntoConstraints = false
            page.snp.makeConstraints { make in
                make.width.equalTo(self.snp.width)
            }
        }
        
    }
    
    
    func setPage(page:Int) {
        self.layoutIfNeeded() // принудительно обновить фреймы и получить уже обновленый фрейм а не ждать пока из констейнтов сама система будет вычеслять фреймы
        
        let xVal = CGFloat(page) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: xVal, y: 0), animated: true)
        
        delegate?.didScrollToPage(index: page)
        
    }
    
    func getCurrPage()->Int{
        self.layoutIfNeeded()
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        return Int(pageNumber)
    }
    

    

}


extension MyViewPager: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        delegate?.didScrollToPage(index: Int(pageNumber))
    }
}




protocol ViewPagerDelegate {
    func didScrollToPage(index: Int)
}
